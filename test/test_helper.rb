if ENV["CI"]
  require "simplecov"
  require "coveralls"
  Coveralls.wear!
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.root(File.expand_path("../..", __FILE__))
end

require "minitest/autorun"
require "mocha/setup"
require "tco_method"

require "test_helpers/vm_stack_helper"
require "test_helpers/factorial_stack_buster_helper"
require "test_helpers/vanilla_stack_buster_helper"

# Use alternate shoulda-style DSL for tests
class TCOMethod::TestCase < Minitest::Spec
  class << self
    alias :setup :before
    alias :teardown :after
    alias :context :describe
    alias :should :it
  end
end
