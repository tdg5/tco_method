require "test_helpers/stack_busters/factorial_stack_buster"

module TCOMethod
  module TestHelpers
    module FactorialStackBusterHelper
      extend Forwardable

      def_delegators "#{self.name}.stack_buster", :unoptimized_factorial

      long_alias =  :factorial_stack_buster_stack_depth_remaining
      def_delegator "#{self.name}.stack_buster", :stack_depth_remaining, long_alias

      def self.stack_buster
        @@stack_buster ||= StackBusters::FactorialStackBuster.new
      end

      def assert_unoptimized_factorial_stack_overflow(depth)
        # Subtract 1 to account for this methiod call since result should be
        # relative to caller
        unoptimized_factorial(depth - 1)
        assert false, "Factorial for depth #{depth} did not overflow!"
      rescue SystemStackError
        assert true
      end
    end
  end
end
