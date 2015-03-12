require "test_helper"

class MethodInfoTest < TCOMethod::TestCase
  Subject = TCOMethod::MethodInfo

  TestClass = Class.new do
    def def_method; end
    define_method(:block_method) { }
  end

  context "#type" do
    subject { TestClass.new }
    should "return :method for methods defined using def" do
      assert_equal :method, Subject.new(subject.method(:def_method)).type
    end

    should "return :block for methods defined using define_method" do
      assert_equal :block, Subject.new(subject.method(:block_method)).type
    end
  end
end
