require "method_source"
require "tco_method/version"
require "tco_method/mixin"
require "tco_method/block_with_tco"

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

  # Allows for executing a block of code with tail call optimization enabled.
  #
  # All code that is evaluated in the block will be evaluated with tail call
  # optimization enabled, however here be dragons, so be warned of a few things:
  #
  # 1. Though it may not be obvious, any call to `require`, `load`, or similar
  # methods from within the block will be evaluated by another part of the VM
  # and will not be tail call optimized. This applies for `tco_eval` as well.
  #
  # 2. The block will be evaluated with a different binding than the binding it
  # was defined in. That means that references to variables or other binding
  # context will result in method errors. For example:
  #
  #     some_variable = "Hello, World!"
  #     womp_womp = TCOMethod.with_tco { some_variable }
  #     # => NameError: Undefined local variable or method 'some_variable'
  #
  # 3. Though this approach is some what nicer than working with strings of
  # code, it comes with the tradeoff that it relies on the the `method_source`
  # gem to do the work of finding the source of the block. There are situations
  # where `method_source` can't accurately determine the source location of a
  # block. That said, if you don't format your code like a maniac, you should be
  # fine.
  #
  # @param [Proc] block The proc to evaluate with tail call optimization
  #   enabled.
  # @return [Object] Returns whatever the result of evaluating the given block.
  def self.with_tco(&block)
    raise ArgumentError, "Block required" unless block_given?
    BlockWithTCO.new(&block).result
  end
end
