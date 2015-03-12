require "test_helper"

class TCOMethodTest < TCOMethod::TestCase
  include TCOMethod::TestHelpers::FactorialStackBusterHelper

  Subject = TCOMethod

  TestClass = Class.new do
    extend TCOMethod::Mixin

    class << self;
      define_method(:class_block_method) { }
    end

    def self.class_factorial(n, acc = 1)
      n <= 1 ? acc : class_factorial(n - 1, n * acc)
    end

    define_method(:instance_block_method)  { }

    def instance_factorial(n, acc = 1)
      n <= 1 ? acc : instance_factorial(n - 1, n * acc)
    end
  end

  subject { Subject }

  context Subject.name do
    should "be defined" do
      assert defined?(subject), "Expected #{subject.name} to be defined!"
    end
  end

  context "::tco_eval" do
    should "raise ArgumentError unless code is a String" do
      bad_code = [
        :bad_code,
        5,
        proc { puts "hello" },
      ]
      bad_code.each do |non_code|
        assert_raises(ArgumentError) do
          subject.tco_eval(non_code)
        end
      end
    end

    should "compile the given code with tail call optimization" do
      FactorialEvalDummy = dummy_class = Class.new
      subject.tco_eval(<<-CODE)
        class #{dummy_class.name}
          def factorial(n, acc = 1)
            n <= 1 ? acc : factorial(n - 1, n * acc)
          end
        end
      CODE

      # Exceed maximum available stack depth by 100 for good measure
      factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
      assert_unoptimized_factorial_stack_overflow(factorial_seed)

      expected_result = iterative_factorial(factorial_seed)
      assert_equal expected_result, dummy_class.new.factorial(factorial_seed)
    end
  end

  context "::reevaluate_method_with_tco" do
    subject { Subject.method(:reevaluate_method_with_tco) }

    context "validation" do
      should "raise ArgumentError unless receiver given" do
        assert_raises(ArgumentError) do
          subject.call(nil, :nil?, :instance)
        end
      end

      should "raise ArgumentError unless method name given" do
        assert_raises(ArgumentError) do
          subject.call(TestClass, nil, :instance)
        end
      end

      should "raise ArgumentError unless method owner given" do
        assert_raises(ArgumentError) do
          subject.call(TestClass, :class_factorial, nil)
        end
      end

      should "raise TypeError for block methods" do
        assert_raises(TypeError) do
          subject.call(TestClass, :class_block_method, :class)
        end
        assert_raises(TypeError) do
          subject.call(TestClass, :instance_block_method, :instance)
        end
      end
    end

    context "with class method" do
      should "raise NameError if no class method with given name defined" do
        assert_raises(NameError) do
          subject.call(TestClass, :marmalade, :class)
        end
      end

      should "re-compile the given method with tail call optimization" do
        # Exceed maximum available stack depth by 100 for good measure
        factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
        assert_raises(SystemStackError) do
          TestClass.class_factorial(factorial_seed)
        end

        subject.call(TestClass, :class_factorial, :class)
        expected_result = iterative_factorial(factorial_seed)
        assert_equal expected_result, TestClass.class_factorial(factorial_seed)
      end
    end

    context "with instance method" do
      should "raise NameError if no instance method with given name defined" do
        assert_raises(NameError) do
          subject.call(TestClass, :marmalade, :instance)
        end
      end

      should "re-compile the given method with tail call optimization" do
        # Exceed maximum available stack depth by 100 for good measure
        factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
        assert_raises(SystemStackError) do
          TestClass.new.instance_factorial(factorial_seed)
        end

        subject.call(TestClass, :instance_factorial, :instance)
        expected_result = iterative_factorial(factorial_seed)
        assert_equal expected_result, TestClass.new.instance_factorial(factorial_seed)
      end
    end
  end
end
