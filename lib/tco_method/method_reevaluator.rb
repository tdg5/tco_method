require "tco_method/method_info"

module TCOMethod
  class MethodReevaluator
    # Reevaluates a method with tail call optimization enabled.
    #
    # @note This class is not part of the public API and should not be used
    #   directly. See {TCOMethod::Mixin} for a module that provides publicly
    #   supported access to the behaviors provided by this method.
    # @param [Class, Module] receiver The Class or Module for which the specified
    #   module, class, or instance method should be reevaluated with tail call
    #   optimization enabled.
    # @param [String, Symbol] method_name The name of the method that should be
    #   reevaluated with tail call optimization enabled.
    # @param [Symbol] method_owner A symbol representing whether the specified
    #   method is expected to be owned by a class, module, or instance.
    # @raise [ArgumentError] Raised if receiver, method_name, or method_owner
    #   argument is omitted.
    # @raise [TypeError] Raised if the specified method is not a method that can
    #   be reevaluated with tail call optimization enabled.
    def initialize(receiver, method_name, method_owner)
      raise ArgumentError, "Receiver required!" unless receiver
      raise ArgumentError, "Method name required!" unless method_name
      raise ArgumentError, "Method owner required!" unless method_owner
      if method_owner == :instance
        existing_method = receiver.instance_method(method_name)
      elsif method_owner == :class || method_owner== :module
        existing_method = receiver.method(method_name)
      end
      method_info = MethodInfo.new(existing_method)
      if method_info.type != :method
        raise TypeError, "Invalid method type: #{method_info.type}"
      end
      receiver_class = receiver.is_a?(Class) ? :class : :module
      code = <<-CODE
        #{receiver_class} #{receiver.name}
          #{existing_method.source}
        end
      CODE

      file, line = existing_method.source_location
      TCOMethod.tco_eval(code, file, File.dirname(file), line - 1)
    end
  end
end
