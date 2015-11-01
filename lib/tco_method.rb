require "method_source"
require "tco_method/version"
require "tco_method/mixin"

# The namespace for the TCOMethod gem. Home to private API methods employed by
# the {TCOMethod::Mixin} module to provide tail call optimized behavior to
# extending Classes and Modules.
module TCOMethod
  # Options that must be provided to RubyVM::InstructionSequence in order to
  # compile code with tail call optimization enabled. Beyond simply enabling the
  # `tailcall optimization` option, the `trace_instruction` option must also be
  # disabled because the RubyVM doesn't currently support `set_trace_func` for
  # code that is compiled with tail call optimization.
  ISEQ_OPTIONS = {
    tailcall_optimization: true,
    trace_instruction: false,
  }.freeze

  # Provides a mechanism for evaluating Strings of code with tail call
  # optimization enabled.
  #
  # @param [String] code The code to evaluate with tail call optimization
  #   enabled.
  # @return [Object] Returns the value of the final expression of the provided
  #   code String.
  # @raise [ArgumentError] if the provided code argument is not a String.
  def self.tco_eval(code, file = nil, path = nil, line = nil)
    raise ArgumentError, "Invalid code string!" unless code.is_a?(String)
    RubyVM::InstructionSequence.new(code, file, path, line, ISEQ_OPTIONS).eval
  end
end
