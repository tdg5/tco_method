module TCOMethod
  # Class encapsulating the behaviors required to extract information about a
  # method from the 14-element Array of data representing the instruction
  # sequence of that method.
  class MethodInfo
    # A collection of those classes that will be recognized as methods and can
    # be used effectively with this class.
    VALID_METHOD_CLASSES = [
      Method,
      UnboundMethod,
    ].freeze

    # Creates a new MethodInfo instance.
    #
    # @param [Method] method_obj The Method or UnboundMethod object representing
    #   the method for which more information should be retrieved.
    # @raise [TypeError] Raised if the provided method object is not a Method or
    #   Unbound method.
    # @see VALID_METHOD_CLASSES
    def initialize(method_obj)
      unless VALID_METHOD_CLASSES.any? { |klass| method_obj.is_a?(klass) }
        msg = "Invalid argument! Method or UnboundMethod expected, received #{method_obj.class.name}"
        raise TypeError, msg
      end
      @info = RubyVM::InstructionSequence.of(method_obj).to_a
    end

    # Returns the type of the method object as reported by the Array of data
    # describing the instruction sequence representing the method.
    #
    # @return [Symbol] A Symbol identifying the type of the instruction
    #   sequence. Typical values will be :method or :block, but all of the
    #   following are valid return values: :top, :method, :block, :class,
    #   :rescue, :ensure, :eval, :main, and :defined_guard.
    def type
      @info[9]
    end
  end
end
