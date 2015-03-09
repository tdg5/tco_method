module TCOMethod
  private

  def tco_method(method_name, method_proc = nil)
    unless method_name || block_given?
      raise ArgumentError, "Method or block required!"
    end
    method_proc ||= Proc.new
    TCOMethod.compile_method(self, method_name, method_proc)
  end

  # tco_proc
  # tco_lambda
  # tco_eval
  # tco_instance_eval
  # tco_class_eval
  # tco_module_eval
end
