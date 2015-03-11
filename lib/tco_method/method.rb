module TCOMethod

  def tco_method(method_name, method_proc = nil)
    unless method_name || block_given?
      raise ArgumentError, "Method or block required!"
    end
    method_proc ||= Proc.new
    compile_tco_method(self, method_name, method_proc)
  end

  def compile_tco_method(receiver, method_name, method_proc)
    lambda_code = method_proc.source.sub(/\A.+do ?\|/, "define_method(:#{method_name}) do |")
    lambda_code = "#{receiver.class.name.downcase} #{receiver.name}\n#{lambda_code}\nend"
    puts lambda_code
    method_lambda = RubyVM::InstructionSequence.new(lambda_code, nil, nil, nil, ISEQ_OPTIONS).eval
    #receiver.send(:define_method, method_name, method_lambda)
  end

  # tco_proc
  # tco_lambda
  # tco_eval
  # tco_instance_eval
  # tco_class_eval
  # tco_module_eval
end
