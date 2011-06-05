module Constructable
  class Constructor
    def initialize(klass)
      @options = []
      @klass = klass
      constructor = self
      @klass.define_singleton_method(:new) do |*args, &block|
        obj = self.allocate
        constructor.construct(args.pop, obj)
        obj.send :initialize, *args, &block
        obj
      end
    end

    def define_options(options)
      @options.concat options.map! { |c| Option.new(*c) }
      options.each do |options|
        options.permissions.each do |permission|
          @klass.send(:"attr_#{permission}", options.name)
        end
      end
    end

    def construct(constructor_hash, obj)
      constructor_hash ||= {}
      @options.each do |options|
        obj.instance_variable_set(options.ivar_symbol, options.process(constructor_hash))
      end
    end
  end
end
