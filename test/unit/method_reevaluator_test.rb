require "test_helper"

module TCOMethod
  class MethodReevaluatorTest < TestCase
    include TCOMethod::TestHelpers::Assertions

    Subject = MethodReevaluator

    context "#initialize" do
      subject { Subject.method(:new) }

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
end
