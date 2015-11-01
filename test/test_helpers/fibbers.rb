# A couple of test classes used for testing tail call optimization in various
# contexts.
module TCOMethod
  test_subject_builder = proc do
    extend TCOMethod::Mixin

    class << self
      define_method(:singleton_block_method) { }
    end

    # Equivalent to the below, but provides a target for verifying that
    # tco_module_method works on Classes and tco_class_method works on Modules.
    def self.module_fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : module_fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end

    # Equivalent to the above, but provides a target for verifying that
    # tco_module_method works on Classes and tco_class_method works on Modules.
    def self.class_fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : class_fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end

    define_method(:instance_block_method)  { }

    # Equivalent to the above, but provides a target for verifying that
    # instance methods work for both Classes and Modules
    def instance_fib_yielder(index, back_one = 1, back_two = 0, &block)
      yield back_two if index > 0
      index < 1 ? back_two : instance_fib_yielder(index - 1, back_one + back_two, back_one, &block)
    end
  end

  TestModule = Module.new(&test_subject_builder)
  TestClass = Class.new(&test_subject_builder)
end
