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
          limit = stack_depth_limit_for_frame_size(LARGEST_VM_STACK_SIZE * 2)
          loop do
            begin
              unoptimized_factorial(limit)
              limit *= 2
            rescue SystemStackError => e
              return e.backtrace.length
            end
          end
        end
      end
    end
  end
end
