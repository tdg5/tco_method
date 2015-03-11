require "test_helper"

class MethodTest < TCOMethod::TestCase
  Subject = Class.new { extend TCOMethod }

  subject { Subject.new }

  context "#tco_method" do
    should "raise ArgumentError unless method or block given" do
      assert_raises(ArgumentError) do
        Subject.send(:tco_method, :factorial)
      end
    end

    $count = 0
    should "compile the given method with tail call optimization" do
      Subject.instance_eval do
        tco_method(:factorial_helper) do |n, acc|
          n <= 1 ? acc : factorial_helper(n - 1, n * acc)
        end

        define_method(:factorial) do |n|
          factorial_helper(n, 1)
        end
      end
      assert_equal 35660, Subject.new.factorial(10_000).to_s.length
    end
  end
end
