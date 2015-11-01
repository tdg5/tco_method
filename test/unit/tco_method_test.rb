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

      should "delegate to an instance of WithTCOBlock" do
        block = proc { "Hello, world!" }
        expected_result = block.call
        instance = TCOMethod::BlockWithTCO.new(&block)
        TCOMethod::BlockWithTCO.expects(:new).with(block).returns(instance)
        instance.expects(:result).returns(expected_result)
        result = TCOMethod.with_tco(&block)
        assert_equal expected_result, result
      end
    end
  end
end
