require "tco_method/version"
require "method_source"
require "tco_method/tco_method"
require "pry"

module TCOMethod
  ISEQ_OPTIONS = {
    tailcall_optimization: true,
    trace_instruction: false,
  }.freeze

  def self.compile_method(receiver, method_name, method_proc)
    lambda_code = method_proc.source.sub(/\A.+do ?\|/, "define_method(:#{method_name}) do |")
    lambda_code = "#{receiver.class.name.downcase} #{receiver.name}\n#{lambda_code}\nend"
    puts lambda_code
    method_lambda = RubyVM::InstructionSequence.new(lambda_code, nil, nil, nil, ISEQ_OPTIONS).eval
    #receiver.send(:define_method, method_name, method_lambda)
  end
end
