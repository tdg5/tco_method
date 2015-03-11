require "pry"

module TCOMethod
  module TestHelpers
    module StackBusters
      class FactorialStackBuster
        include VMStackHelper

        def frame_size
          @frame_size ||= vm_stack_size / stack_overflow_threshold
        end

        def unoptimized_factorial(n, acc = 1)
          n <= 1 ? acc : unoptimized_factorial(n - 1, n * acc)
        end

        def stack_depth_remaining
          stack_depth_remaining_for_frame_size(frame_size)
        end

        private

        # Stack buster based on binary search for point of stack oveflow of
        # unoptimized_factorial
        def stack_overflow_threshold
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
            return last_overflow_limit if last_overflow_limit == last_good_limit + 1
            begin
              half_the_distance_to_overflow = (last_overflow_limit - limit) / 2
              limit += half_the_distance_to_overflow
              unoptimized_factorial(limit)
              last_good_limit = limit
            rescue SystemStackError
              last_overflow_limit = limit
              limit = last_good_limit
            end
          end
        end
      end
    end
  end
end
