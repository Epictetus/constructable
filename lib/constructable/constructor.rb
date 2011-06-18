module Constructable
  class Constructor
    attr_accessor :attributes

    def initialize(base)
      @attributes = []
      @module = Module.new
      @base = base
      @base.send :include, @module
      self.redefine_new_calling
      self.define_concstructable_attributes_method
    end

    def redefine_new_calling
      case @base
      when Class
        self.redefine_new(@base)
      when Module
        constructor = self
        redefine_new_logic = proc do |base|
          base.instance_variable_set(:@constructor, constructor)
          if Class == base.class
            constructor.redefine_new(base)
          elsif Module == base.class
            base.define_singleton_method :included, &redefine_new_logic
          end
        end
        @base.define_singleton_method :included, &redefine_new_logic
      end
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
        @module.module_eval do
          attr_reader attribute.name

          define_method(:"#{attribute.name}=") do |value|
            instance_variable_set attribute.ivar_symbol, attribute.process(value)
          end
          private attribute.name unless attribute.readable
          private :"#{attribute.name}=" unless attribute.writable
        end
      end
    end

    def construct(constructor_hash, obj)
      constructor_hash ||= {}
      @attributes.each do |attribute|
        obj.send :"#{attribute.name}=", constructor_hash[attribute.name]
      end
    end

    def generate_attributes(attributes)
      options = if Hash === attributes.last
        attributes.pop
      else
        {}
      end

      attributes.map do |attribute|
        Attribute.new(attribute, options)
      end
    end

    def define_concstructable_attributes_method
      constructor = self
      @base.module_eval do
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
