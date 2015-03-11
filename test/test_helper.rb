require "minitest/autorun"
require "mocha/setup"
require "tco_method"

# Use alternate shoulda-style DSL for tests
class TCOMethod::TestCase < Minitest::Spec
  LARGEST_VM_STACK_SIZE = 128

  class << self
    alias :setup :before
    alias :teardown :after
    alias :context :describe
    alias :should :it
  end

  def self.stack_buster_stack_frame_size
    @@stack_buster_stack_frame_size ||= vm_stack_size / stack_buster
  end

  def self.factorial_stack_buster_frame_size
    @@factorial_stack_buster_stack_frame_size ||= vm_stack_size / factorial_stack_buster
  end

  def self.vm_stack_size
    ENV["RUBY_THREAD_VM_STACK_SIZE"] || RubyVM::DEFAULT_PARAMS[:thread_vm_stack_size]
  end

  def self.stack_depth_limit_for_frame_size(frame_size)
    vm_stack_size / frame_size
  end

  def self.stack_depth_remaining_for_frame_size(frame_size)
    stack_depth_limit_for_frame_size(frame_size) - caller.length + 1
  end

  private

  def assert_unoptimized_factorial_stack_overflow(depth)
    # Subtract 1 to account for this methiod call since result should be
    # relative to caller
    self.class.unoptimized_factorial(depth - 1)
    assert false, "Factorial for depth #{depth} did not overflow!"
  rescue SystemStackError
    assert true
  end

  def self.unoptimized_factorial(n, acc = 1)
    n <= 1 ? acc : unoptimized_factorial(n - 1, n * acc)
  end

  # binary search for point of stack oveflow of unoptimized_factorial
  def self.factorial_stack_buster
    # Use a frame size that's larger than the expected frame size to ensure
    # that limit is less than the point of overflow
    limit = last_good_limit = stack_depth_limit_for_frame_size(LARGEST_VM_STACK_SIZE * 2)
    last_overflow_limit = nil
    # Determine an upper-bound for binary search
    loop do
      begin
        unoptimized_factorial(limit)
        last_good_limit = limit
        limit *= 2
      rescue SystemStackError
        last_overflow_limit = limit
        break
      end
    end

    # Reset for binary search for point of stack overflow
    limit = last_good_limit
    loop do
      begin
        half_the_distance_to_overflow = (last_overflow_limit - limit) / 2
        limit += half_the_distance_to_overflow
        unoptimized_factorial(limit)
        last_good_limit = limit
      rescue SystemStackError
        return limit if last_good_limit == limit - 1
        last_overflow_limit = limit
        limit = last_good_limit
      end
    end
  end

  def self.factorial_stack_buster_stack_depth_remaining
    stack_depth_remaining_for_frame_size(factorial_stack_buster_frame_size)
  end

  def self.stack_buster(depth = 1)
    stack_buster(depth + 1)
  rescue SystemStackError
    depth
  end

  def self.stack_buster_stack_depth_remaining
    stack_depth_remaining_for_frame_size(stack_buster_frame_size)
  end
end
