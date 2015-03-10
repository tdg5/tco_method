module TCOMethod
  def tco_eval(code)
    raise ArgumentError, "Invalid code string!" unless code.is_a?(String)
    TCOMethod.tco_eval(code)
  end
end
