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

      context "#tco_method" do
        should "call MethodReevaluator#new with expected arguments" do
          method_name = :some_method
          args = [subject, method_name, :instance]
          MethodReevaluator.expects(:new).with(*args)
          subject.tco_method(method_name)
        end
      end

      context "#tco_eval" do
        should "call TCOMethod.tco_eval with expected arguments" do
          code = "some_code"
          TCOMethod.expects(:tco_eval).with(code)
          subject.tco_eval(code)
        end
      end

      context "#with_tco" do
        should "call TCOMethod.with_tco with the given block" do
          # Mocha doesn't offer a good way for sensing passed blocks, so run
          # through the process twice, once with a stub, once without.

          # Stubbed
          TCOMethod.expects(:with_tco).returns(true)
          assert_equal true, subject.with_tco { }

          # Now unstubbed to make sure the expected block is invoked.
          TCOMethod.unstub(:with_tco)

          # Must use some sort of global for sensing side effects because the
          # block given to with_tco is called with a different binding than the
          # one used here.
          module ::WithTCOSensor
            def self.call; @called = true; end
            def self.called?; !!@called; end
          end

          result = subject.with_tco { ::WithTCOSensor.call; ::WithTCOSensor }
          assert_equal true, ::WithTCOSensor.called?
          assert_equal ::WithTCOSensor, result
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
