require "test_helper"

class MethodInfoTest < TCOMethod::TestCase
  Subject = TCOMethod::MethodInfo

  TestClass = Class.new do
    class << self; define_method(:class_block_method) { }; end
    def self.class_def_method; end
    define_method(:instance_block_method) { }
    def instance_def_method; end
  end

  context "#initialize" do
    should "raise TypeError unless given a Method object" do
      non_methods = [
        proc { },
        lambda { },
        Proc.new { },
      ]
      non_methods.each do |non_method|
        assert_raises(TypeError) do
          Subject.new(non_method)
        end
      end
    end

    should "accept Method objects defined on a class using def" do
      method_obj = TestClass.method(:class_def_method)
      assert_kind_of Method, method_obj
      assert_kind_of Subject, Subject.new(method_obj)
    end

    should "accept UnboundMethod objects defined on an instance using def" do
      method_obj = TestClass.instance_method(:instance_def_method)
      assert_kind_of UnboundMethod, method_obj
      assert_kind_of Subject, Subject.new(method_obj)
    end

    should "accept Method objects defined on a class using define_method" do
      method_obj = TestClass.method(:class_block_method)
      assert_kind_of Method, method_obj
      assert_kind_of Subject, Subject.new(method_obj)
    end

    should "accept UnboundMethod objects defined on an instance using define_method" do
      method_obj = TestClass.instance_method(:instance_block_method)
      assert_kind_of UnboundMethod, method_obj
      assert_kind_of Subject, Subject.new(method_obj)
    end
  end

  context "#type" do
    subject { TestClass.new }
    should "return :method for methods defined using def" do
      assert_equal :method, Subject.new(TestClass.method(:class_def_method)).type
      assert_equal :method, Subject.new(subject.method(:instance_def_method)).type
    end

    should "return :block for methods defined using define_method" do
      assert_equal :block, Subject.new(TestClass.method(:class_block_method)).type
      assert_equal :block, Subject.new(subject.method(:instance_block_method)).type
    end
  end
end
