module TCOMethod
  def tco_eval(code)
    raise ArgumentError, "Invalid code string!" unless code.is_a?(String)
    RubyVM::InstructionSequence.new(code, nil, nil, nil, ISEQ_OPTIONS).eval
  end
end
