module Constructable
  class Constructor
    def initialize(klass)
      @attributes = []
      @klass = klass
      constructor = self
      @klass.define_singleton_method(:new) do |*args, &block|
        obj = self.allocate
        constructor.execute_initalizers(args.pop, obj)
        obj.send :initialize, *args, &block
        obj
      end
    end

    def define_constructors(constructors)
      @attributes.concat constructors
      constructors.each do |attr|
        @klass.send(:attr_accessor, (attr.is_a?(Array) ? attr.first : attr))
      end
    end

    def execute_initalizers(constructor_hash, obj)
      constructor_hash ||= {}
      @attributes.each do |attr|
        case attr
        when Symbol
          symbol = attr
        when Array
          if attr.last == :required && !constructor_hash[attr.first]
            raise ArgumentError, "#{attr.first} needs to be a key in the constructor hash"
          end
          symbol = attr.last
        end
        obj.instance_variable_set(:"@#{symbol}", constructor_hash[symbol])
      end
    end
  end
end
