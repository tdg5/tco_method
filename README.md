# TCOMethod
[![Gem Version](https://badge.fury.io/rb/tco_method.svg)](http://badge.fury.io/rb/tco_method)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/tco_method)
[![Build Status](https://travis-ci.org/tdg5/tco_method.svg)](https://travis-ci.org/tdg5/tco_method)
[![Coverage Status](https://coveralls.io/repos/tdg5/tco_method/badge.svg)](https://coveralls.io/r/tdg5/tco_method)
[![Code Climate](https://codeclimate.com/github/tdg5/tco_method/badges/gpa.svg)](https://codeclimate.com/github/tdg5/tco_method)
[![Dependency Status](https://gemnasium.com/tdg5/tco_method.svg)](https://gemnasium.com/tdg5/tco_method)

Provides `TCOMethod::Mixin` for extending Classes and Modules with helper methods
to facilitate evaluating code and some types of methods with tail call
optimization enabled in MRI Ruby. Also provides `TCOMethod.tco_eval` providing a
direct and easy means to evaluate code strings with tail call optimization
enabled.

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

Extend a class with the [`TCOMethod::Mixin`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin)
and let the fun begin!

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

Or, for more power and flexibility (at the cost of stringified code blocks) use
[`TCOMethod.tco_eval`](http://www.rubydoc.info/gems/tco_method/TCOMethod/Mixin:tco_eval)
directly:

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

You can kind of get around this by dynamically reading the code you want to
compile with tail call optimization, but this approach also has downsides in
that it goes around the standard Ruby `require` model. For example, consider the
Fibonacci example broken across two scripts, one script serving as a loader and
the other script acting as a more standard library:

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

If you really want to get crazy, you could include the `TCOMethod::Mixin` module
in the Module class and add these behaviors to all Modules and Classes. To quote
VIM plugin author extraordinaire Tim Pope, "I don't like to get crazy." Consider
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

Quirks with Module and Class annotations:
- Annotations only work with methods defined using the `def` keyword.
- Annotations use the [`method_source` gem](https://github.com/banister/method_source)
  to retrieve the method source to reevaluate. As a result, class annotations
  can act strangely when used in more dynamic contexts like `irb` or `pry`.
- Annotations reopen the Module or Class by name to redefine the given method.
  This process will fail for dynamic Modules and Classes that aren't assigned to
  constants and, ergo, don't have names.

I'm sure there are more and I will document them here as I come across them.

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
  optimization
- For more background on how tail call optimization is implemented in MRI Ruby,
  see [Danny Guinther's *Tail Call Optimization in Ruby: Deep Dive*](http://blog.tdg5.com/tail-call-optimization-ruby-deep-dive/)
- For those on flavors of Ruby other than MRI, check out [Magnus Holm's *Tailin'
  Ruby*](http://timelessrepo.com/tailin-ruby) for some insight into how else
  tail call optimization (or at least tail call optimization like behavior) can
  be achieved in Ruby
