module TCOMethod
  # Class encapsulating the behaviors required to extract information about a
  # method from the 14-element Array of data representing the instruction
  # sequence of that method.
  class MethodInfo
    VALID_METHOD_CLASSES = [
      Method,
      UnboundMethod,
    ].freeze

    def initialize(method_obj)
      unless VALID_METHOD_CLASSES.any? { |klass| method_obj.is_a?(klass) }
        msg = "Invalid argument! Method or UnboundMethod expected, received #{method_obj.class.name}"
        raise TypeError, msg
      end
      @info = RubyVM::InstructionSequence.of(method_obj).to_a
    end

    def type
      @info[9]
    end
  end
end
