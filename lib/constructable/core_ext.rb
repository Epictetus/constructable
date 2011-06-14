module Constructable
  class ::Module
    include Constructable

    # @example
    #
    #  class Foo
    #    constructable [:bar, :readable => true], [:baz, :required => true, :readable => true]
    #  end
    #
    #  foo = Foo.new(bar: 5)
    #  # raises AttributeError, ':baz is a required attribute'
    #
    #  foo = Foo.new(baz: 7, bar: 5)
    #
    #  foo.bar
    #  # => 5
    #  foo.baz
    #  # => 7
    #
    #  class ProgrammingLanguage
    #    constructable [:paradigms,
    #      readable: true,
    #      required: true,
    #      validate: ->(value) { value.is_a?(Array) }]
    #  end
    #
    #  c = ProgrammingLanguage.new(paradigms: :functional)
    #  #  raises AttributeError, ':paradigms did not pass validation'
    #
    #  ruby = ProgrammingLanguage.new(paradigms: [:object_oriented, :functional])
    #  ruby.paradigms
    #  # => [:object_oriented, :functional]
    #
    # @param [Array<[Array<Symbol, Hash>]>] args an array of symbols or arrays: the name of the attribute and it's configuration
    def constructable(*args)
      @constructor ||= Constructor.new(self)
      @constructor.define_attributes(args)
      case self
      when Class
        @constructor.redefine_new(self)
      when Module
        define_singleton_method :included do |base|
          @constructor.redefine_new(base) if Class === base
        end
      end
      return nil
    end
  end
end
