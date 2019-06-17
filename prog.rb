require './filter.rb'

class MyClass
  include Filters

  private def foo
    puts 'I am foo'
  end

  private def baz
    puts 'I am baz'
  end

  def bar
    puts 'I am bar'
  end

  def bat
    puts 'I am bat'
  end

  def ball
    puts 'I am ball'
  end

  # before_filter :baz

  action_methods :bar, :bat, :ball

  before_filter :foo, :only => [:bat]
  after_filter :baz, :except => [:bat]
end

MyClass.new.bar
MyClass.new.bat
MyClass.new.ball
