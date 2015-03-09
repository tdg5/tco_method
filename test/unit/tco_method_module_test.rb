require "test_helper"

class TCOMethodModuleTest < TCOMethod::TestCase
  Subject = TCOMethod

  context Subject.name do
    subject { Subject }

    should "be defined" do
      assert defined?(subject), "Expected #{subject.name} to be defined!"
    end
  end
end
