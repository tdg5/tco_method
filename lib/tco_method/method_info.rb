module TCOMethod
  class MethodInfo
    def initialize(method)
      @info = RubyVM::InstructionSequence.of(method).to_a
    end

    def type
      @info[9]
    end
  end
end
