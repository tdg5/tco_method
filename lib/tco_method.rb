require "tco_method/version"
require "tco_method/eval"

module TCOMethod
  ISEQ_OPTIONS = {
    tailcall_optimization: true,
    trace_instruction: false,
  }.freeze
end
