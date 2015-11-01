require "pry"
require "test_helper"

module TCOMethod
  class BlockExtractorTest < TestCase
    Subject = BlockExtractor
    subject { Subject }

    blocks = [
      :lambda_brace_inline,
      :lambda_brace_multi,
      :lambda_do_inline,
      :lambda_do_multi,
      :method_brace_inline,
      :method_brace_multi,
      :method_do_inline,
      :method_do_multi,
      :proc_brace_inline,
      :proc_brace_multi,
      :proc_do_inline,
      :proc_do_multi,
    ]

    unsourceable_blocks = [
      :ambiguous_procs,
      :a_hash_with_an_ambiguous_proc,
      :an_ambiguous_proc_with_hash,
      :an_unsourceable_proc,
    ]

    context "block extraction" do
      blocks.each do |meth|
        should "extract block in #{meth} form" do
          block = send(meth)
          block_source = subject.new(block).source
          reblock = eval(block_source)
          reblock_result = reblock.call

          # Ensure both blocks return the same result
          assert_equal block.call, reblock_result

          # Ensure a lambda is used where appropriate
          assert_equal reblock_result == :lambda, reblock.lambda?
        end
      end

      unsourceable_blocks.each do |meth|
        should "raise when given a #{meth}" do
          block = send(meth)
          assert_raises(AmbiguousSourceError) { subject.new(block).source }
        end
      end

      should "correctly strip trailing code at the end of the block" do
        # The ').source' below should be plenty to test this concern.
        block_source = subject.new(lambda do
          "Hold on to your butts"
        end).source
        begin
          eval(block_source)
        rescue SyntaxError
          assert false, "Syntax error in block source"
        end
      end
    end

    # This ambiguity could be handled, but encourages poorly formatted code and
    # doesn't seem worth the effort presently.
    def a_hash_with_an_ambiguous_proc
      {}; proc { :proc }
    end

    def ambiguous_procs
      proc { :please }; proc { :dont_do_this }
    end

    def an_unsourceable_proc
      {
        :block => proc { :method_source_error }
      }[:block]
    end

    # This ambiguity could be handled, but encourages poorly formatted code and
    # doesn't seem worth the effort presently.
    def an_ambiguous_proc_with_hash
      block = proc { :proc }; {}
      block
    end

    def lambda_brace_inline
      lambda { :lambda }
    end

    def lambda_brace_multi
      lambda {
        :lambda
      }
    end

    def lambda_do_inline
      lambda do; :lambda; end
    end

    def lambda_do_multi
      lambda do
        :lambda
      end
    end

    def method_brace_inline
      Proc.new { :proc }
    end

    def method_brace_multi
      Proc.new {
        :proc
      }
    end

    def method_do_inline
      Proc.new do; :proc; end
    end

    def method_do_multi
      Proc.new do
        :proc
      end
    end

    def proc_do_inline
      proc do; :proc; end
    end

    def proc_do_multi
      proc do
        :proc
      end
    end

    def proc_brace_inline
      proc { :proc }
    end

    def proc_brace_multi
      proc {
        :proc
      }
    end
  end
end
