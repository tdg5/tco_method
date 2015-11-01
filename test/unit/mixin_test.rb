require "test_helper"

module TCOMethod
  class MixinTest < TCOMethod::TestCase
    TestClass = Class.new { extend TCOMethod::Mixin }
    TestModule = Module.new { extend TCOMethod::Mixin }


    context "Module extensions" do
      subject { TestModule }

      context "#tco_module_method" do
        should "call MethodReevaluator#new with expected arguments" do
          method_name = :some_method
          args = [subject, method_name, :module]
          MethodReevaluator.expects(:new).with(*args)
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
        should "call MethodReevaluator#new with expected arguments" do
          method_name = :some_method
          args = [subject, method_name, :instance]
          MethodReevaluator.expects(:new).with(*args)
          subject.tco_method(method_name)
        end
      end
    end

    context "Class extensions" do
      subject { TestClass }

      context "#tco_class_method" do
        should "call MethodReevaluator#new with expected arguments" do
          method_name = :some_method
          args = [subject, method_name, :module]
          MethodReevaluator.expects(:new).with(*args)
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
        should "call MethodReevaluator#new with expected arguments" do
          method_name = :some_method
          args = [subject, method_name, :instance]
          MethodReevaluator.expects(:new).with(*args)
          subject.tco_method(method_name)
        end
      end
    end
  end
end
