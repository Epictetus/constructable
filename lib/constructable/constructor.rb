module Constructable
  class Constructor
    attr_accessor :attributes

    def initialize(klass)
      @attributes = []
      @klass = klass
      self.redefine_new(klass)
      self.define_concstructable_attributes_method
    end

    def redefine_new(klass)
      constructor = self
      klass.define_singleton_method(:new) do |*args, &block|
        obj = self.allocate
        constructor_hash = Hash === args.last ? args.last : {}
        constructor.construct(constructor_hash, obj)
        obj.send :initialize, *args, &block
        obj
      end
    end


    def define_attributes(attributes)
      attributes = generate_attributes(attributes)
      @attributes.concat attributes

      attributes = @attributes
      attributes.each do |attribute|
        @klass.class_eval do
          attr_reader attribute.name if attribute.readable

          define_method(:"#{attribute.name}=") do |value|
            instance_variable_set attribute.ivar_symbol, attribute.process({ attribute.name => value})
          end if attribute.writable
        end
      end
    end

    def construct(constructor_hash, obj)
      constructor_hash ||= {}
      @attributes.each do |attributes|
        obj.instance_variable_set(attributes.ivar_symbol, attributes.process(constructor_hash))
      end
    end

    def generate_attributes(attributes)
      attributes.map do |attribute|
        Attribute.new(*attribute)
      end
    end

    def define_concstructable_attributes_method
      constructor = self
      @klass.class_eval do
        define_method :constructable_attributes do
          Hash[
            constructor.attributes
            .map { |a| [a.name,instance_variable_get(a.ivar_symbol)] }
            .select(&:last)
          ]
        end
      end
    end
  end
end
