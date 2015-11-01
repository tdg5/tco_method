require "test_helper"

module TCOMethod
  class BlockWithTCOTest < TestCase
    include TCOMethod::TestHelpers::Assertions

    Subject = BlockWithTCO

    context "::with_tco" do
      subject { Subject }

      should "raise ArgumentError if a block is not given" do
        exception = assert_raises(ArgumentError) { subject.new }
        assert_match(/block required/i, exception.message)
      end

      # It would be nice if it could evaluate the block with the same binding, but
      # I haven't been able to find a way to make that work.
      should "evaluate the provided block with a different binding" do
        some_variable = "Hello, world!"
        assert_raises(NameError) do
          subject.new { some_variable }
        end
      end

      should "work with a proc in block form" do
        tco_block = subject.new do
          "Hello, world!"
        end
        assert_equal "Hello, world!", tco_block.result
      end

      should "work with a proc in curly-brace form" do
        tco_block = subject.new { "Hello, world!" }
        assert_equal "Hello, world!", tco_block.result
      end

      should "be tail call optimized" do
        subject.new do
          class ::TCOTester
            def fib_yielder(index, back_one = 1, back_two = 0, &block)
              index > 0 ? yield(back_two) : (return back_two)
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
