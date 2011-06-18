module Constructable
  class Attribute
    ATTRIBUTES = [:group, :writable, :readable, :accessible, :required, :validate, :default, :validate_type, :converter]
    attr_accessor *ATTRIBUTES, :name

    REQUIREMENTS = [
      {
        name: :validate_type,
        message: proc {":#{self.name} must be of type #{self.validate_type}"},
        check: ->(value) { value.is_a? self.validate_type }
      },
      {
        name: :validate,
        message: proc {":#{self.name} did not pass validation"},
        check: ->(value) { self.validate.call(value)}
      }
    ]

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

    def check_for_requirement(requirement, value)
      if self.send requirement[:name]
        unless self.instance_exec(value,&requirement[:check])
          raise AttributeError, instance_eval(&requirement[:message])
        end
      end
    end
    private :check_for_requirement

    def process(value)
      unless value.nil?
        REQUIREMENTS.each do |requirement|
          check_for_requirement(requirement, value)
        end
        self.converter ? converter.(value) : value
      else
        raise AttributeError, ":#{self.name} is a required attribute" if self.required
        self.default.call if self.default
      end
    end
  end
end
