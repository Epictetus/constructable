module Constructable
  class Constructor
    def initialize(klass)
      @attributes = []
      @klass = klass
      constructor = self
      @klass.define_singleton_method(:new) do |*args, &block|
        obj = self.allocate
        constructor_hash = Hash === args.last ? args.pop : {}
        constructor.construct(constructor_hash, obj)
        obj.send :initialize, *args, &block
        obj
      end
    end


    def define_attributes(attributes)
      @attributes.concat attributes.map! { |c| Attribute.new(*c) }
      attributes.each do |attribute|
        @klass.class_eval do
          setter = :"#{attribute.name}="
          define_method(attribute.name) { instance_variable_get attribute.ivar_symbol }
          private attribute.name unless attribute.readable
          define_method(setter) { |value| instance_variable_set attribute.ivar_symbol, attribute.process({ attribute.name => value}) }
          private setter unless attribute.writable
        end
      end
    end

    def construct(constructor_hash, obj)
      constructor_hash ||= {}
      @attributes.each do |attributes|
        obj.instance_variable_set(attributes.ivar_symbol, attributes.process(constructor_hash))
      end
    end
  end
end
