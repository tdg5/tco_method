require "tco_method/block_extractor"

module TCOMethod
  class BlockWithTCO
    attr_reader :result

    def initialize(&block)
      raise ArgumentError, "Block required" unless block
      @result = eval(block)
    end

    private

    def extract_source(block)
      BlockExtractor.new(block).source
    end

    def eval(block)
      TCOMethod.tco_eval(extract_source(block)).call
    end
  end
end
