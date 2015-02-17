require "minitest/autorun"
require "mocha/setup"
require "tco_method"

# Use alternate shoulda-style DSL for tests
class TCOMethod::TestCase < Minitest::Spec
  class << self
    alias :setup :before
    alias :teardown :after
    alias :context :describe
    alias :should :it
  end
end
