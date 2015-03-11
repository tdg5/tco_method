require "test_helper"

class TCOEvalTest < TCOMethod::TestCase
  Subject = Class.new { extend TCOMethod }

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
          Subject.send(:tco_eval, non_code)
        end
      end
    end

    should "compile the given code with tail call optimization" do
      Subject.tco_eval(<<-CODE)
        class TCOEvalTest::Subject
          def factorial(n, acc = 1)
            n <= 1 ? acc : factorial(n - 1, n * acc)
          end
        end
      CODE

      expected_result = 1

      factorial_seed = self.class.factorial_stack_buster_stack_depth_remaining + 1
      assert_unoptimized_factorial_stack_overflow(factorial_seed)

      factorial_seed.times { |multiplier| expected_result *= multiplier + 1 }
      assert_equal expected_result, Subject.new.factorial(factorial_seed)
    end
  end
end
