module TCOMethod
  # Exception raised when it's not possible to reliably determine the source
  # code of a block.
  class AmbiguousSourceError < StandardError
    # Default message template.
    MESSAGE = "Could not determine source of block".freeze

    # Returns the exception that this exception was created to wrap if any such
    # exception exists. Used only when this exception is created to wrap
    # another.
    attr_accessor :original_exception

    # Create an exception from a problematic block.
    #
    # @param [Proc] block The block for which the source is ambiguous.
    # @return [AmbiguousBlockError] A new exception instance wrapping the given
    #   exception.
    def self.from_proc(block)
      new(MESSAGE + " #{block.inspect}")
    end

    # Wrap another exception with an AmbiguousBlockError. Useful for wrapping
    # errors raised by MethodSource.
    #
    # @param [Exception] exception The exception instance that should be
    #   wrapped.
    # @return [AmbiguousBlockError] A new exception instance wrapping the given
    #   exception.
    def self.wrap(exception)
      error = new(exception.message)
      error.original_exception = exception
      error
    end

    # Creates a new instance of the exception.
    #
    # @param [String] message The message to use with the exception.
    def initialize(message = MESSAGE)
      super
    end
  end
end
