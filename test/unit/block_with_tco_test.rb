require "test_helper"

module TCOMethod
  class BlockWithTCOTest < TestCase
    Subject = BlockWithTCO

  context "::with_tco" do
    subject { Subject }

    should "raise ArgumentError if a block is not given" do
      exception = assert_raises(ArgumentError) { subject.new }
      assert_match(/block required/i, exception.message)
    end

    should "evaluate the provided block with the correct binding" do
      some_variable = "Hello, world!"
      result = subject.new { some_variable }
      assert_equal some_variable, result
    end

    should "work with a proc in block form" do
      some_variable = "Hello, world!"
      result = subject.new do
        some_variable
      end
      assert_equal some_variable, result
    end

    should "work with a proc in curly-brace form" do
      some_variable = "Hello, world!"
      result = subject.new { some_variable }
      assert_equal some_variable, result
    end

    should "be tail call optimized" do
      subject.new do
        class ::TCOTester
          def fib_yielder(index, back_one = 1, back_two = 0, &block)
            yield back_two if index > 0
            return back_two if index < 1
            fib_yielder(index - 1, back_one + back_two, back_one, &block)
          end
        end
      end
      meth = ::TCOTester.new.method(:fib_yielder)
      assert_equal true, tail_call_optimized?(meth, 5)
    end
  end
  end
end
