module TCOMethod
  module TestHelpers
    module Assertions
      def assert_tail_call_optimized(method, *args)
        is_tco = tail_call_optimized(method, *args)
        msg = "Expected method #{method.name} to be tail call optimized"
        assert is_tco, msg
      end

      def refute_tail_call_optimized(method, *args)
        is_tco = tail_call_optimized(method, *args)
        msg = "Expected method #{method.name} not to be tail call optimized"
        refute is_tco, msg
      end

      def tail_call_optimized?(method, *args)
        initial_length = nil
        method.call(*args) do
          if initial_length.nil?
            initial_length = caller.length
          else
            break initial_length == caller.length
          end
        end
      end
    end
  end
end
