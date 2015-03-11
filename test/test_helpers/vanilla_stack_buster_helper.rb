require "test_helpers/stack_busters/vanilla_stack_buster"

module TCOMethod
  module TestHelpers
    module VanillaStackBusterHelper
      extend Forwardable

      def_delegator "#{self.name}.stack_buster", :stack_depth_remaining, :vanilla_stack_depth_remaining

      def self.stack_buster
        @@stack_buster ||= StackBusters::VanillaStackBuster.new
      end
      private_class_method :stack_buster
    end
  end
end
