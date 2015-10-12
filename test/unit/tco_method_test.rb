require "test_helper"

class TCOMethodTest < TCOMethod::TestCase
  include TCOMethod::TestHelpers::Assertions

  Subject = TCOMethod

  test_subject_builder = proc do
    extend TCOMethod::Mixin

    class << self
      define_method(:singleton_block_method) { }
    end

    # Equivalent to the below, but provides a target for verifying that
    # tco_module_method works on Classes and tco_class_method works on Modules.
    def self.module_fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : module_fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end

    # Equivalent to the above, but provides a target for verifying that
    # tco_module_method works on Classes and tco_class_method works on Modules.
    def self.class_fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : class_fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end

    define_method(:instance_block_method)  { }

    # Equivalent to the above, but provides a target for verifying that
    # instance methods work for both Classes and Modules
    def instance_fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : instance_fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end
  end

  TestModule = Module.new(&test_subject_builder)
  TestClass = Class.new(&test_subject_builder)

  # Grab source before it's recompiled for use later
  InstanceFibYielderSource = TestClass.instance_method(:instance_fib_yielder).source

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
      EvalDummy = dummy_class = Class.new
      subject.tco_eval(<<-CODE)
        class #{dummy_class.name}
          #{InstanceFibYielderSource}
        end
      CODE

      fib_yielder = dummy_class.new.method(:instance_fib_yielder)
      assert tail_call_optimized?(fib_yielder, 5)
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
            fib_yielder = method_owner.method(:module_fib_yielder)
            refute tail_call_optimized?(fib_yielder, 5)

            subject.call(method_owner, :module_fib_yielder, :module)
            tco_fib_yielder = method_owner.method(:module_fib_yielder)
            assert tail_call_optimized?(tco_fib_yielder, 5)

            assert_equal fib_yielder.source_location, tco_fib_yielder.source_location
          end
        end

        context "with class method" do
          should "raise NameError if no class method with given name defined" do
            assert_raises(NameError) do
              subject.call(method_owner, :marmalade, :class)
            end
          end

          should "re-compile the given method with tail call optimization" do
            fib_yielder = method_owner.method(:class_fib_yielder)
            refute tail_call_optimized?(fib_yielder, 5)

            subject.call(method_owner, :class_fib_yielder, :module)
            tco_fib_yielder = method_owner.method(:class_fib_yielder)
            assert tail_call_optimized?(tco_fib_yielder, 5)

            assert_equal fib_yielder.source_location, tco_fib_yielder.source_location
          end
        end

        context "with instance method" do
          should "raise NameError if no instance method with given name defined" do
            assert_raises(NameError) do
              subject.call(method_owner, :marmalade, :instance)
            end
          end

          should "re-compile the given method with tail call optimization" do
            instance_class = instance_class_for_receiver(method_owner)

            fib_yielder = instance_class.new.method(:instance_fib_yielder)
            refute tail_call_optimized?(fib_yielder, 5)

            subject.call(method_owner, :instance_fib_yielder, :instance)
            tco_fib_yielder = instance_class.new.method(:instance_fib_yielder)
            assert tail_call_optimized?(tco_fib_yielder, 5)

            assert_equal fib_yielder.source_location, tco_fib_yielder.source_location
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
