require "test_helper"

module TCOMethod
  class TCOMethodTest < TCOMethod::TestCase
    include TCOMethod::TestHelpers::Assertions

    Subject = TCOMethod

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

    context "::with_tco" do
      should "raise ArgumentError if a block is not given" do
        exception = assert_raises(ArgumentError) { subject.with_tco }
        assert_match(/block required/i, exception.message)
      end

      should "compile the given code with tail call optimization" do
        subject.with_tco do
          class WithTCODummy
            def countdown(count, &block)
              yield count
              count.zero? ? 0 : countdown(count - 1, &block)
            end
          end
        end

        meth = WithTCODummy.new.method(:countdown)
        assert tail_call_optimized?(meth, 5)
      end
    end
  end
end
