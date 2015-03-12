require "test_helper"

class MethodTest < TCOMethod::TestCase
  include TCOMethod::TestHelpers::FactorialStackBusterHelper

  Subject = Class.new do
    extend TCOMethod

    class << self
      define_method :class_block_method do
        puts "Hello, world!"
      end
    end

    def self.class_factorial(n, acc = 1)
      n <= 1 ? acc : class_factorial(n - 1, n * acc)
    end

    def instance_factorial(n, acc = 1)
      n <= 1 ? acc : instance_factorial(n - 1, n * acc)
    end

    define_method :instance_block_method do
      puts "Hello, world!"
    end
  end

  subject { Subject.new }

  context "#tco_class_method" do
    should "raise ArgumentError unless method name given" do
      assert_raises(ArgumentError) { Subject.send(:tco_class_method) }
    end

    should "raise NameError if no instance method with given name defined" do
      assert_raises(NameError) { Subject.send(:tco_class_method, :marmalade) }
    end

    should "raise TypeError for block methods" do
      assert_raises(TypeError) { Subject.send(:tco_class_method, :class_block_method) }
    end

    should "re-compile the given method with tail call optimization" do
      # Exceed maximum available stack depth by 100 for good measure
      factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
      assert_raises(SystemStackError) do
        Subject.class_factorial(factorial_seed)
      end

      Subject.instance_eval { tco_class_method(:class_factorial) }
      expected_result = iterative_factorial(factorial_seed)
      assert_equal expected_result, Subject.class_factorial(factorial_seed)
    end
  end

  context "#tco_method" do
    should "raise ArgumentError unless method name given" do
      assert_raises(ArgumentError) { Subject.send(:tco_method) }
    end

    should "raise NameError if no instance method with given name defined" do
      assert_raises(NameError) { Subject.send(:tco_method, :marmalade) }
    end

    should "raise TypeError for block methods" do
      assert_raises(TypeError) { Subject.send(:tco_method, :instance_block_method) }
    end

    should "re-compile the given method with tail call optimization" do
      # Exceed maximum available stack depth by 100 for good measure
      factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
      assert_raises(SystemStackError) do
        subject.instance_factorial(factorial_seed)
      end

      Subject.instance_eval { tco_method(:instance_factorial) }
      expected_result = iterative_factorial(factorial_seed)
      assert_equal expected_result, Subject.new.instance_factorial(factorial_seed)
    end
  end
end
