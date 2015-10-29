require "method_source"
require "tco_method/version"
require "tco_method/method_info"
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

  # Mutex used to ensure that nothing else tries to evaluate code while the
  # global RubyVM::InstructionSequence object is in a non-default state.
  ISEQ_MUTEX = Mutex.new

  # Reevaluates a method with tail call optimization enabled.
  #
  # @note This method is not part of the public API and should not be used
  #   directly. See {TCOMethod::Mixin} for a module that provides publicly
  #   supported access to the behaviors provided by this method.
  # @param [Class, Module] receiver The Class or Module for which the specified
  #   module, class, or instance method should be reevaluated with tail call
  #   optimization enabled.
  # @param [String, Symbol] method_name The name of the method that should be
  #   reevaluated with tail call optimization enabled.
  # @param [Symbol] method_owner A symbol representing whether the specified
  #   method is expected to be owned by a class, module, or instance.
  # @return [Symbol] The symbolized method name.
  # @raise [ArgumentError] Raised if receiver, method_name, or method_owner
  #   argument is omitted.
  # @raise [TypeError] Raised if the specified method is not a method that can
  #   be reevaluated with tail call optimization enabled.
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
    receiver_class = receiver.is_a?(Class) ? :class : :module
    code = <<-CODE
      #{receiver_class} #{receiver.name}
        #{existing_method.source}
      end
    CODE

    file, line = existing_method.source_location
    tco_eval(code, file, File.dirname(file), line - 1)
    method_name.to_sym
  end

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

  def self.tco_load(path)
    with_global_tco { load(path) }
  end

  def self.tco_require(path)
    with_global_tco { require(path) }
  end

  def self.require_tco!
    if !RubyVM::InstructionSequence.compile_option[:tailcall_optimization]
      with_global_tco do
        calling_file = caller[4].gsub(/.rb:[0-9]+.*$/, '')
        require(calling_file)
      end
      return false
    end
    true
  end

  def self.token_tco_method(first = true)
    return unless first
    token_tco_method
  end

  def self.with_global_tco
    raise ArgumentError, "block required" unless block_given?
    ISEQ_MUTEX.synchronize do
      begin
        initial_options = RubyVM::InstructionSequence.compile_option
        mod_options = initial_options.merge(ISEQ_OPTIONS)
        RubyVM::InstructionSequence.compile_option = mod_options
        yield
      ensure
        RubyVM::InstructionSequence.compile_option = initial_options
      end
    end
  end
end
