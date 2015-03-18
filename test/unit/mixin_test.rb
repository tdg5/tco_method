require "test_helper"

class MixinTest < TCOMethod::TestCase
  TestClass = Class.new { extend TCOMethod::Mixin }
  TestModule = Module.new { extend TCOMethod::Mixin }


  context "Module extensions" do
    subject { TestModule }

    context "#tco_module_method" do
      should "call TCOMethod.reevaluate_method_with_tco with expected arguments" do
        method_name = :some_method
        args = [subject, method_name, :module]
        TCOMethod.expects(:reevaluate_method_with_tco).with(*args)
        subject.tco_module_method(method_name)
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
        args = [subject, method_name, :instance]
        TCOMethod.expects(:reevaluate_method_with_tco).with(*args)
        subject.tco_method(method_name)
      end
    end
  end

  context "Class extensions" do
    subject { TestClass }

    context "#tco_class_method" do
      should "call TCOMethod.reevaluate_method_with_tco with expected arguments" do
        method_name = :some_method
        args = [subject, method_name, :module]
        TCOMethod.expects(:reevaluate_method_with_tco).with(*args)
        subject.tco_class_method(method_name)
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
        args = [subject, method_name, :instance]
        TCOMethod.expects(:reevaluate_method_with_tco).with(*args)
        subject.tco_method(method_name)
      end
    end
  end
end
