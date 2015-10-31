require "ripper"

module TCOMethod
  class BlockWithTCO
    def initialize(&block)
      raise ArgumentError, "Block required" unless block
      @block = block
      eval
    end

    private

    def extract_source
      binding.pry
      "'Womp womp'"
    end

    def eval
      code = extract_source
      # Regrettable hack required to make the block's binding available to the
      # context in which the modified code block will be evaluated. Other ideas
      # are welcome!
      thread_variable = "tco_block_binding_#{object_id}".to_sym
      puts "WTF: #{thread_variable}"
      puts "WTF: #{thread_variable}"
      Thread.current[thread_variable] = @block.binding
      executor = %Q[Thread.current["#{thread_variable}"].eval(#{code.inspect})]
      TCOMethod.tco_eval(executor)
    ensure
      puts "HUH?: #{thread_variable}"
      Thread.current[thread_variable] = nil
    end
  end
end
