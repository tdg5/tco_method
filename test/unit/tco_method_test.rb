require 'test_helper'

class TCOMethodTest < TCOMethod::TestCase
  SUBJECT = TCOMethod

  context SUBJECT.name do
    subject { SUBJECT }

    should 'be defined' do
      assert defined?(subject), "Expected #{subject.name} to be defined!"
    end
  end
end
