require "test_helper"

class TCOEvalTest < TCOMethod::TestCase
  include TCOMethod::TestHelpers::FactorialStackBusterHelper

  Subject = Class.new { include TCOMethod }

  subject { Subject.new }

  context "#tco_eval" do
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
end
