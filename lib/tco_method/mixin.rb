module TCOMethod
  module Mixin
    def tco_class_method(method_name)
      TCOMethod.reevaluate_method_with_tco(self, method_name, :class)
    end
    alias_method :tco_module_method, :tco_class_method

    def tco_eval(code)
      TCOMethod.tco_eval(code)
    end

    def tco_method(method_name)
      TCOMethod.reevaluate_method_with_tco(self, method_name, :instance)
    end
  end
end
