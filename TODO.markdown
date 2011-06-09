
* add group option to attributes
```ruby
class Foo
  constructable [:bar, group: :shizzle], [:baz, group: :shizzle]
end

foo = Foo.new(bar: 5, baz: 8)

foo.shizzle
#=> { bar: 5, baz: 8 }
```
