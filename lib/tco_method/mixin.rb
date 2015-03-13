module TCOMethod
  # Mixin providing tail call optimization eval and class annotations. When
  # extended by a Class or Module adds methods for evaluating code with tail
  # call optimization enabled and re-evaluating existing methods with tail call
  # optimization enabled.
  module Mixin
    # Module or Class annotation causing the class or module method identified
    # by the given method name to be reevaluated with tail call optimization
    # enabled. Only works for methods defined using the `def` keyword.
    #
    # @param [String, Symbol] method_name The name of the class or module method
    #   that should be reeevaluated with tail call optimization enabled.
    # @return [Symbol] The symbolized method name.
    # @see TCOMethod.reevaluate_method_with_tco
    def tco_module_method(method_name)
      TCOMethod.reevaluate_method_with_tco(self, method_name, :module)
    end
    alias_method :tco_class_method, :tco_module_method

    # Evaluate the given code String with tail call optimization enabled.
    #
    # @param [String] code The code to evaluate with tail call optimization
    #   enabled.
    # @return [Object] Returns the value of the final expression of the provided
    #   code String.
    # @raise [ArgumentError] if the provided code argument is not a String.
    # @see TCOMethod.tco_eval
    def tco_eval(code)
      TCOMethod.tco_eval(code)
    end

    # Class annotation causing the instance method identified by the given
    # method name to be reevaluated with tail call optimization enabled. Only
    # works for methods defined using the `def` keyword.
    #
    # @param [String, Symbol] method_name The name of the instance method that
    #   should be reeevaluated with tail call optimization enabled.
    # @return [Symbol] The symbolized method name.
    # @see TCOMethod.reevaluate_method_with_tco
    def tco_method(method_name)
      TCOMethod.reevaluate_method_with_tco(self, method_name, :instance)
    end
  end
end
