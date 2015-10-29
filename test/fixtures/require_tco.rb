if TCOMethod.require_tco!
  module RequireTCOTester
    bump
    def self.fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end
  end
end
