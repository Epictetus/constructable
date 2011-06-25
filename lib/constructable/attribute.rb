module Constructable
  class Attribute
    ATTRIBUTES = [:group, :writable, :readable, :accessible, :required, :default, :converter]
    attr_accessor *ATTRIBUTES, :name

    def initialize(name, options = {})
      @name = name
      ATTRIBUTES.each do |attribute|
        self.send(:"#{attribute}=", options[attribute])
      end
    end

    def accessible=(boolean)
      if boolean
        self.readable = true
        self.writable = true
      end
    end

    def ivar_symbol
      ('@' + self.name.to_s).to_sym
    end

    def attr_writer_symbol
      (self.name.to_s + '=').to_sym
    end

    def process(value)
      unless value.nil?
        self.converter ? converter.(value) : value
      else
        raise AttributeError, ":#{self.name} is a required attribute" if self.required
        self.default.call if self.default
      end
    end
  end
end
