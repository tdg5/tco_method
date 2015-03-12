# TCOMethod
[![Gem Version](https://badge.fury.io/rb/tco_method.svg)](http://badge.fury.io/rb/tco_method)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/tco_method)
[![Build Status](https://travis-ci.org/tdg5/tco_method.svg)](https://travis-ci.org/tdg5/tco_method)
[![Coverage Status](https://coveralls.io/repos/tdg5/tco_method/badge.svg)](https://coveralls.io/r/tdg5/tco_method)
[![Code Climate](https://codeclimate.com/github/tdg5/tco_method/badges/gpa.svg)](https://codeclimate.com/github/tdg5/tco_method)
[![Dependency Status](https://gemnasium.com/tdg5/tco_method.svg)](https://gemnasium.com/tdg5/tco_method)

Provides `TCOMethod::Mixin` for extending Classes and Modules with helper methods
to facilitate evaluating code and some types of methods with tail call
optimization enabled. Also provides `TCOMethod.tco_eval` providing an easy means
to evaluate code strings with tail call optimization enabled.

## Installation

Add this line to your application's Gemfile:

```bash
gem 'tco_method'
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

Require the `TCOMethod` library:

```ruby
require "tco_method"
```

Extend a class with the `TCOMethod::Mixin` and enjoy!

```ruby
class MyClass
  extend TCOMethod::Mixin

  def factorial(n, acc = 1)
    n <= 1 ? acc : factorial(n - 1, n * acc)
  end
  tco_method :factorial
end

MyClass.new.factorial(10_000).to_s.length
# => 35660
```

Or, use `TCOMethod.tco_eval` directly. Cumbersome, but much more flexible and
powerful:

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

## Gotchas

The list so far:

- Currently only works with methods defined using the `def` keyword.
- Class annotations use the [`method_source` gem](https://github.com/banister/method_source)
  to retrieve the method source to reevaluate. As a result, class annotations
  can act strangely when used in more dynamic contexts like `irb` or `pry`.


I'm sure there are more and I will document them here as I come across them.

## Contributing

1. Fork it ( https://github.com/tdg5/tco_method/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
