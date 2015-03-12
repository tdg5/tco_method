module TCOMethod

  def tco_method(method_name)
    compile_tco_method(method_name, :instance)
  end

  def tco_class_method(method_name)
    compile_tco_method(method_name, :class)
  end

  private

  def compile_tco_method(method_name, method_receiver)
    raise ArgumentError, "Method name required!" unless method_name
    if method_receiver == :instance
      existing_method = instance_method(method_name)
    elsif method_receiver == :class || method_reciver == :module
      existing_method = method(method_name)
    end
    method_info = MethodInfo.new(existing_method)
    if method_info.type != :method
      raise TypeError, "Invalid method type: #{method_info.type}"
    end
    code = <<-CODE
      class #{name}
        #{existing_method.source}
      end
    CODE
    tco_eval(code)
  end
end
