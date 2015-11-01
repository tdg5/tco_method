if ENV["CI"]
  require "simplecov"
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.root(File.expand_path("../..", __FILE__))
  SimpleCov.start do
    add_filter "test"
  end
end

require "minitest/autorun"
require "mocha/setup"
require "tco_method"
require "test_helpers/assertions"
require "test_helpers/fibbers"

# Use alternate shoulda-style DSL for tests
class TCOMethod::TestCase < Minitest::Spec
  class << self
    alias :setup :before
    alias :teardown :after
    alias :context :describe
    alias :should :it
  end
end
