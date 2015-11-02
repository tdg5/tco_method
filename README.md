# TCOMethod
[![Gem Version](https://badge.fury.io/rb/tco_method.svg)](http://badge.fury.io/rb/tco_method)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/tco_method)
[![Build Status](https://travis-ci.org/tdg5/tco_method.svg?branch=master)](https://travis-ci.org/tdg5/tco_method)
[![Coverage Status](https://coveralls.io/repos/tdg5/tco_method/badge.svg)](https://coveralls.io/r/tdg5/tco_method)
[![Code Climate](https://codeclimate.com/github/tdg5/tco_method/badges/gpa.svg)](https://codeclimate.com/github/tdg5/tco_method)
[![Dependency Status](https://gemnasium.com/tdg5/tco_method.svg)](https://gemnasium.com/tdg5/tco_method)

The `tco_method` gem provides a number of different APIs to facilitate
evaluating code with tail call optimization enabled in MRI Ruby.

The `TCOMethod.with_tco` method is perhaps the simplest means of evaluating code
with tail call optimization enabled. `TCOMethod.with_tco` takes a block and
compiles all code **in that block** with tail call optimization enabled.

The `TCOMethod::Mixin` module extends Classes and Modules with helper methods
(kind of like method annotations) to facilitate compiling some types of methods
with tail call optimization enabled.

The `TCOMethod.tco_eval` method provides a direct means to evaluate code strings
with tail call optimization enabled. This API is the most cumbersome, but it can
be useful for loading full files with tail call optimization enabled (see
examples below). It is also the foundation of all of the other `TCOMethod` APIs.

Be warned, there are a few gotchas. For example, even when using one of the APIs
provided by the `tco_method` gem, `require`, `load`, and `Kernel#eval` still
won't evaluate code with tail call optimization enabled without changing the
`RubyVM` settings globally.  More on the various limitations of the `tco_method`
gem are outlined in the docs in the
[Gotchas](http://www.rubydoc.info/gems/tco_method/file/README.md#Gotchas)
section.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tco_method"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install tco_method
```

## Usage

Require the [`TCOMethod`](http://www.rubydoc.info/gems/tco_method/TCOMethod)
library:

```ruby
require "tco_method"
```

### `TCOMethod.with_tco`

The fastest road to tail call optimized glory is the
[`TCOMethod.with_tco`](http://www.rubydoc.info/gems/tco_method/TCOMethod#with_tco-class_method)
method. Using
[`TCOMethod.with_tco`](http://www.rubydoc.info/gems/tco_method/TCOMethod#with_tco-class_method)
you can evaluate a block of code with tail call optimization enabled liked so:

```ruby
TCOMethod.with_tco do
  class MyClass
    def factorial(n, acc = 1)
      n <= 1 ? acc : factorial(n - 1, n * acc)
    end
  end
end

puts MyClass.new.factorial(10_000).to_s.length
# => 35660
```

It's worth noting that in the example above the actual optimized tail call
occurs outside of the `TCOMethod.with_tco` block. `TCOMethod.with_tco` is used
to compile code in such a way that tail call optimization is enabled. Once
compiled, the tail call optimized code can be invoked from anywhere in the
program.

### `TCOMethod::Mixin`

Alternatively, you can extend a Class or Module with the
[`TCOMethod::Mixin`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin)
and let the TCO fun begin using helpers that act like method annotations.

To redefine an instance method with tail call optimization enabled, use
[`tco_method`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin:tco_method):

```ruby
class MyClass
  extend TCOMethod::Mixin

  def factorial(n, acc = 1)
    n <= 1 ? acc : factorial(n - 1, n * acc)
  end
  tco_method :factorial
end

puts MyClass.new.factorial(10_000).to_s.length
# => 35660
```

Or alternatively, use [`tco_module_method`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin:tco_module_method)
or [`tco_class_method`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin:tco_module_method)
for a Module or Class method:

```ruby
module MyFibonacci
  extend TCOMethod::Mixin

  def self.fibonacci(index, back_one = 1, back_two = 0)
    index < 1 ? back_two : fibonacci(index - 1, back_one + back_two, back_one)
  end
  tco_module_method :fibonacci
end

puts MyFibonacci.fibonacci(10_000).to_s.length
# => 2090
```

### `TCOMethod.tco_eval`

Finally, depending on your needs (and your love for stringified code blocks),
you can also use
[`TCOMethod.tco_eval`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin:tco_eval)
directly.
[`TCOMethod.tco_eval`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin:tco_eval)
can be useful in situations where the `method_source` gem is unable to determine
the source of a particular block or for loading entire files with tail call
optimization enabled.

```ruby
TCOMethod.tco_eval(<<-CODE)
  class MyClass
    def factorial(n, acc = 1)
      n <= 1 ? acc : factorial(n - 1, n * acc)
    end
  end
CODE

MyClass.new.factorial(10_000).to_s.length
# => 35660
```

You can kind of get around the need for stringified code blocks by reading the
code you want to compile with tail call optimization dynamically at runtime, but
this approach also has downsides in that it goes around the standard Ruby
`require`/`load` process. For example, consider the `Fibonacci` example broken across
two scripts, one script serving as a loader and the other script acting as a
more standard library:

```ruby
# loader.rb

require "tco_method"
fibonacci_lib = File.read(File.expand_path("../fibonacci.rb", __FILE__))
TCOMethod.tco_eval(fibonacci_lib)

puts MyFibonacci.fibonacci(10_000).to_s.length
# => 2090


# fibonacci.rb

module MyFibonacci
  def self.fibonacci(index, back_one = 1, back_two = 0)
    index < 1 ? back_two : fibonacci(index - 1, back_one + back_two, back_one)
  end
end
```

If you really want to get crazy, you can include the `TCOMethod::Mixin` module
in the `Module` class to add these behaviors to all Modules and Classes. To quote
VIM plugin author extraordinaire, Tim Pope, "I don't like to get crazy." Consider
yourself warned.

```ruby
# Don't say I didn't warn you...

Module.include(TCOMethod::Mixin)

module MyFibonacci
  def self.fibonacci(index, back_one = 1, back_two = 0)
    index < 1 ? back_two : fibonacci(index - 1, back_one + back_two, back_one)
  end
  tco_module_method :fibonacci
end

puts MyFibonacci.fibonacci(10_000).to_s.length
# => 2090
```

## Gotchas
**Quirks with the `method_source` gem**:
- Annotations and `TCOMethod.with_tco` use the
  [`method_source` gem](https://github.com/banister/method_source) to retrieve
  the method source to evaluate. As a result, class annotations and
  `TCOMethod.with_tco` can act strangely when used in more dynamic contexts like
  `irb` or `pry`.  Additionally, if the code to be evaluated is formatted in
  unconventional ways, it can make it difficult for `method_source` and/or
  `tco_method` to determine the unambiguous source of the method or code block.
  Most of these ambiguities can be solved by following standard Ruby formating
  conventions.

**Quirks with `TCOMethod.with_tco`**:
- Because the source code of the specified block is determined using the
  `method_source` gem, the given block will be evaluated with a binding
  different from the one it was defined in. Attempts have been made to get around
  this, but so far, no dice. Seems like a job for a C extension.
- `require`, `load`, and `eval` will still load code **without tail call
  optimization enabled** even when called from within a block given to
  `TCOMethod.with_tco`. Each of these methods compiles code using the primary
  `RubyVM::InstructionSequence` object which honors the configuration specified
  by `RubyVM::InstructionSequence.compile_option`.

**Quirks with Module and Class annotations**:
- Annotations only work with methods defined using the `def` keyword.
- Annotations reopen the Module or Class by name to redefine the given method.
  This process will fail for dynamic Modules and Classes that aren't assigned to
  constants and, ergo, don't have names that can be used for lookup.

There are almost certainly more gotchas, so check back for more in the future if
you run into weirdness while using this gem. Issues are welcome.

## Contributing

1. Fork it ( https://github.com/tdg5/tco_method/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Reference

- Class annotations are based on [Nithin Bekal's blog post *Tail Call
  Optimization in Ruby*](http://nithinbekal.com/posts/ruby-tco/) which follows
  his efforts to create a method decorator to recompile methods with tail call
  optimization.
- For more background on how tail call optimization is implemented in MRI Ruby,
  see [Danny Guinther's *Tail Call Optimization in Ruby: Deep Dive*](http://blog.tdg5.com/tail-call-optimization-ruby-deep-dive/).
- For those on flavors of Ruby other than MRI, check out [Magnus Holm's *Tailin'
  Ruby*](http://timelessrepo.com/tailin-ruby) for some insight into how else
  tail call optimization (or at least tail call optimization like behavior) can
  be achieved in Ruby.
