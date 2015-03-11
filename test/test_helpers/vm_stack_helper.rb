module TCOMethod
  module TestHelpers
    module VMStackHelper
      LARGEST_VM_STACK_SIZE = 128

      # Calculate the maximum number of times a stack frame of a given size could
      # be repeated before running out of room on the stack.
      def stack_depth_limit_for_frame_size(frame_size)
        vm_stack_size / frame_size
      end
      module_function :stack_depth_limit_for_frame_size

      # Calculate how many more times a frame could be repeated before running out of
      # room on the stack.
      def stack_depth_remaining_for_frame_size(frame_size)
        stack_depth_limit_for_frame_size(frame_size) - caller.length + 1
      end
      module_function :stack_depth_remaining_for_frame_size

      # Determine maximum size of VM stack for a single thread based on
      # environment or default value.
      def vm_stack_size
        ENV["RUBY_THREAD_VM_STACK_SIZE"] || RubyVM::DEFAULT_PARAMS[:thread_vm_stack_size]
      end
      module_function :vm_stack_size
    end
  end
end
