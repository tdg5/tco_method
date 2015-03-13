require "test_helper"

class TCOMethodTest < TCOMethod::TestCase
  include TCOMethod::TestHelpers::FactorialStackBusterHelper

  Subject = TCOMethod

  test_subject_builder = proc do
    extend TCOMethod::Mixin

    class << self
      define_method(:singleton_block_method) { }
    end

    # Equivalent to the below, but provides a target for verifying that
    # tco_module_method works on Classes and tco_class_method works on Modules.
    def self.module_factorial(n, acc = 1)
      n <= 1 ? acc : module_factorial(n - 1, n * acc)
    end

    # Equivalent to the above, but provides a target for verifying that
    # tco_module_method works on Classes and tco_class_method works on Modules.
    def self.class_factorial(n, acc = 1)
      n <= 1 ? acc : class_factorial(n - 1, n * acc)
    end

    define_method(:instance_block_method)  { }

    def instance_factorial(n, acc = 1)
      n <= 1 ? acc : instance_factorial(n - 1, n * acc)
    end
  end

  TestModule = Module.new(&test_subject_builder)
  TestClass = Class.new(&test_subject_builder)

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

    [TestClass, TestModule].each do |method_owner|
      method_owner_class = method_owner.class.name.downcase.to_sym

      context "validation" do
        should "raise ArgumentError unless receiver given" do
          assert_raises(ArgumentError) do
            subject.call(nil, :nil?, :instance)
          end
        end

        should "raise ArgumentError unless method name given" do
          assert_raises(ArgumentError) do
            subject.call(method_owner, nil, :instance)
          end
        end

        should "raise ArgumentError unless method owner given" do
          assert_raises(ArgumentError) do
            subject.call(method_owner, :class_factorial, nil)
          end
        end

        should "raise TypeError for block methods" do
          assert_raises(TypeError) do
            subject.call(method_owner, :singleton_block_method, :class)
          end
          assert_raises(TypeError) do
            subject.call(method_owner, :instance_block_method, :instance)
          end
        end
      end

      context "#{method_owner_class} receiver" do
        context "with module method" do
          should "raise NameError if no #{method_owner_class} method with given name defined" do
            assert_raises(NameError) do
              subject.call(method_owner, :marmalade, method_owner_class)
            end
          end

          should "re-compile the given method with tail call optimization" do
            # Exceed maximum available stack depth by 100 for good measure
            factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
            assert_raises(SystemStackError) do
              method_owner.module_factorial(factorial_seed)
            end

            subject.call(method_owner, :module_factorial, :module)
            expected_result = iterative_factorial(factorial_seed)
            assert_equal expected_result, method_owner.module_factorial(factorial_seed)
          end
        end

        context "with class method" do
          should "raise NameError if no class method with given name defined" do
            assert_raises(NameError) do
              subject.call(method_owner, :marmalade, :class)
            end
          end

          should "re-compile the given method with tail call optimization" do
            # Exceed maximum available stack depth by 100 for good measure
            factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
            assert_raises(SystemStackError) do
              method_owner.class_factorial(factorial_seed)
            end

            subject.call(method_owner, :class_factorial, method_owner_class)
            expected_result = iterative_factorial(factorial_seed)
            assert_equal expected_result, method_owner.class_factorial(factorial_seed)
          end
        end

        context "with instance method" do
          should "raise NameError if no instance method with given name defined" do
            assert_raises(NameError) do
              subject.call(method_owner, :marmalade, :instance)
            end
          end

          should "re-compile the given method with tail call optimization" do
            # Exceed maximum available stack depth by 100 for good measure
            factorial_seed = factorial_stack_buster_stack_depth_remaining + 100
            instance_class = instance_class_for_receiver(method_owner)
            assert_raises(SystemStackError) do
              instance_class.new.instance_factorial(factorial_seed)
            end

            subject.call(method_owner, :instance_factorial, :instance)
            expected_result = iterative_factorial(factorial_seed)
            assert_equal expected_result, instance_class.new.instance_factorial(factorial_seed)
          end
        end
      end
    end
  end

  def instance_class_for_receiver(receiver)
    return receiver if receiver.is_a?(Class)
    Class.new { include receiver }
  end
end
