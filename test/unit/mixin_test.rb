require "test_helper"

class MixinTest < TCOMethod::TestCase
  include TCOMethod::TestHelpers::FactorialStackBusterHelper

  TestClass = Class.new do
    extend TCOMethod::Mixin
  end

  subject { TestClass }

  [:tco_class_method, :tco_module_method].each do |method_alias|
    context "##{method_alias}" do
      should "call TCOMethod.reevaluate_method_with_tco with expected arguments" do
        method_name = :some_method
        args = [TestClass, method_name, :class]
        TCOMethod.expects(:reevaluate_method_with_tco).with(*args)
        subject.send(method_alias, method_name)
      end
    end
  end

  context "#tco_eval" do
    should "call TCOMethod.eval with expected arguments" do
      code = "some_code"
      TCOMethod.expects(:tco_eval).with(code)
      subject.tco_eval(code)
    end
  end

  context "#tco_method" do
    should "call TCOMethod.reevaluate_method_with_tco with expected arguments" do
      method_name = :some_method
      args = [TestClass, method_name, :instance]
      TCOMethod.expects(:reevaluate_method_with_tco).with(*args)
      subject.tco_method(method_name)
    end
  end
end
