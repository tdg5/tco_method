require "method_source"
require "tco_method/version"
require "tco_method/method_info"
require "tco_method/mixin"

module TCOMethod
  ISEQ_OPTIONS = {
    tailcall_optimization: true,
    trace_instruction: false,
  }.freeze

  def self.reevaluate_method_with_tco(receiver, method_name, method_owner)
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
    code = <<-CODE
      class #{receiver.name}
        #{existing_method.source}
      end
    CODE
    tco_eval(code)
  end

  def self.tco_eval(code)
    raise ArgumentError, "Invalid code string!" unless code.is_a?(String)
    RubyVM::InstructionSequence.new(code, nil, nil, nil, ISEQ_OPTIONS).eval
  end
end
