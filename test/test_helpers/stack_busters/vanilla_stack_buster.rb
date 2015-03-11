module TCOMethod
  module TestHelpers
    module StackBusters
      class VanillaStackBuster
        include VMStackHelper

        def frame_size
          @frame_size ||= vm_stack_size / stack_overflow_threshold
        end

        def stack_depth_remaining
          stack_depth_remaining_for_frame_size(frame_size)
        end

        private

        def stack_overflow_threshold(depth = 1)
          stack_overflow_threshold(depth + 1)
        rescue SystemStackError
          depth
        end
      end
    end
  end
end
