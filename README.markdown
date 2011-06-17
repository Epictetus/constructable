# Constructable [![Build Status](http://travis-ci.org/mkorfmann/constructable.png)](http://travis-ci.org/mkorfmann/constructable)

Provides a powerful class macro for defining and configuring constructable attributes of a class.


## Basic usage

Define you're class like this:

```ruby
require 'constructable'
class ProgrammingLanguage
  constructable :creator, :name
end
```

Then you can construct objects by providing a hash as the last argument
to ProgrammingLanguage.new like this:

```ruby
ruby = ProgrammingLanguage.new(name: 'Ruby', creator: 'Yukihiro
Matsumoto')
```

The object _ruby_ will now have the instance variables @name and
@creator set to 'Ruby' and 'Yukihiro Matsumoto'.

## Setters, Getters

You can define you're constructable attributes as readable, writable or
both:

```ruby
class Train
  constructable :speed, readable: true
  constructable :driver, writable: true
  constructable :location, accsessible: true
end

orient_express = Train.new(speed: 100)
orient_express.speed
#=> 100
orient_express.next_stop = 'Bucarest'
orient_express.next_stop
# raises NoMethodError
orient_express.location = 'Budapest'
orient_express.location
#=> 'Budapest'
```

## Validations

You can setup validation for constructable attributes, so the users of
you're api won't provide weird values or none at all:

### required

```ruby
class Holidays
  constructable :when, required: true
end

summer_holidays = Holidays.new
#=> raises AttributeError, ':when is a required attribute'
```

### validate\_type

```ruby
class Conference
  constructable :attendees, validate_type: Integer
end

euruko = Conference.new('~300') # btw, euruko was really great!
# raises AttributeError, ':attendees must be of type Integer'
```

### validate

```ruby
class Farm
  costructable :animals,
    validate_type: Array,
    validate: ->(array_of_animals) do
      array_of_animals.all? { |animal| animal.is_a?(String) 
    end
end

big_farm = Farm.new(animals: [:pigs, :cows])
# raises AttributeError, ':animals has not passed validation'
```

## Redefining setters and getters

You can redefine the setters and getters in your class but still get the
validation, that the getters and setters provide, which the constructable 
class macro set up for you:

```ruby
class Song
  constructable :length, accessible: true, validate_type: Integer

  def length=(length)
    if length.is_a?(String) && length ~= /(\d{,2}):(\d{,2})
      @length = $1.to_i * 60 + $2.to_i
    else
     super
    end
  end
end

song = Song.new(length: 190)
song.length = '1:30'
song.length = 'abc'
# raises AttributeError, ':length must be of type Integer'
```

## Modules

### WARNING

The constructable macro also works for modules(not for themself, but for
the clasess, you include them) but it will define the 'included' hook.
So if you want to use the 'included' hook yourself, you either need to
around alias it or to use another gem. I tried some things, but it is
impossible, to provide all the magic of this gem, without defining
the 'included' macro. I thought about getting rid of some of the magic,
but this would infer with my initial intention, to provide an easy way
to make constructable classes. If someone has a nice idea, how to solve
this problem elgantely, please contact me!

## Copyright
Copyright (c) 2011 Manuel Korfmann. See LICENSE.txt for
further details.

