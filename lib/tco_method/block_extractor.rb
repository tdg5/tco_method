require "tco_method/ambiguous_source_error"
require "method_source"
require "ripper"

module TCOMethod
  # Object encapsulating the logic to extract the source code of a given block.
  class BlockExtractor
    DO_STR = "do".freeze
    END_STR = "end".freeze

    attr_reader :source

    def initialize(block)
      source = block.source
      type = block.lambda? ? :lambda : :proc
      start_offset, end_offset = determine_offsets(block, source)
      @source = "#{type} #{source[start_offset..end_offset]}"
    rescue MethodSource::SourceNotFoundError => ex
      raise AmbiguousSourceError.wrap(ex)
    end

    private

    # Encapsulates the logic required to determine the offset of the end of the
    # block. The end of the block is characterized by a matching curly brace
    # (`}`) or the `end` keyword.
    def determine_end_offset(block, tokens, source, expected_matcher)
      lines = source.lines
      last_line_number = lines.length
      end_offset = nil
      tokens.reverse_each do |token|
        # Break once we're through with the last line.
        break if token[0][0] != last_line_number

        # Look for expected match to block opener
        next if token[1] != expected_matcher
        next if token[1] == :on_kw && token[2] != END_STR

        # Raise if we've already found something that looks like a block end.
        raise AmbiguousSourceError.from_proc(block) if end_offset
        # Ending offset is the position of the ending token, plus the length of
        # that token.
        end_offset = token[0][1] + token[2].length
      end
      raise AmbiguousSourceError.from_proc(block) unless end_offset
      determine_end_offset_relative_to_source(end_offset, lines.last.length)
    end

    # We subract the length of the last line from end offset to determine the
    # negative offset into the source string. However we must subtract 1 to
    # correct for the negative offset referring to the character after the
    # desired terminal character.
    def determine_end_offset_relative_to_source(end_offset, last_line_length)
      end_offset - last_line_length - 1
    end

    # Tokenizes the source of the block as determined by the `method_source` gem
    # and determines the beginning and end of the block.
    #
    # In both cases the entire line is checked to ensure there's no unexpected
    # ambiguity as to the start or end of the block. See the test file for this
    # class for examples of ambiguous situations.
    #
    # @param [Proc] block The proc for which the starting offset of its source
    # code should be determined.
    # @param [String] source The source code of the provided block.
    # @raise [AmbiguousSourceError] Raised when the source of the block cannot
    #   be determined unambiguously.
    # @return [Array<Integer>] The start and end offsets of the block's source
    #   code as 2-element Array.
    def determine_offsets(block, source)
      tokens = Ripper.lex(source)
      start_offset, start_token = determine_start_offset(block, tokens)
      expected_match = start_token == :on_kw ? :on_kw : :on_rbrace
      end_offset = determine_end_offset(block, tokens, source, expected_match)
      [start_offset, end_offset]
    end

    # The logic required to determine the starting offset of the block. The
    # start of the block is characterized by the opening left curly brace (`{`)
    # of the block or the `do` keyword. Everything prior to the start of the
    # block is ignored because we can determine whether the block should be a
    # lambda or a proc by asking the block directly, and we may not always have
    # such a keyword available to us, e.g. a method that takes a block like
    # TCOMethod.with_tco.
    def determine_start_offset(block, tokens)
      start_offset = start_token = nil
      # The start of the block should occur somewhere on line 1.
      # Check the whole line to ensure there aren't multiple blocks on the line.
      tokens.each do |token|
        # Break after line 1.
        break if token[0][0] != 1

        # Look for a left brace (`{`) or `do` keyword.
        if token[1] == :on_lbrace || (token[1] == :on_kw && token[2] == DO_STR)
          # Raise if we've already found something that looks like a block
          # start.
          raise AmbiguousSourceError.from_proc(block) if start_offset
          start_token = token[1]
          start_offset = token[0][1]
        end
      end
      raise AmbiguousSourceError.from_proc(block) unless start_offset
      [start_offset, start_token]
    end
  end
end
