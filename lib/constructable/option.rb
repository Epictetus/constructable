module Constructable
  class Option
    OPTIONS = [:writable, :readable, :accessible, :required, :validate, :default, :type]
    attr_accessor *OPTIONS, :name

    REQUIRED_REQUIREMENT= {
        name: :required,
        message: proc {":#{self.name} is a required option"},
        check: ->(hash) { hash.has_key?(self.name) }
      }

    REQUIREMENTS = [
      {
        name: :validate,
        message: proc {":#{self.name} did not pass validation"},
        check: ->(hash) { self.validate.call(hash[self.name])}
      },
      {
        name: :type,
        message: proc {":#{self.name} is not of type #{self.type}"},
        check: ->(hash) { self.type === hash[self.name] }
      }
    ]

    def initialize(name, options = {})
      @name = name
      OPTIONS.each do |option|
        self.send(:"#{option}=", options[option])
      end
    end

    def accessible=(boolean)
      if boolean
        self.readable = true
        self.writable = true
      end
    end

    def permissions
      {:readable => :reader,:writable => :writer}.select { |permission,_| self.send permission }.map(&:last)
    end

    def ivar_symbol
      ('@' + self.name.to_s).to_sym
    end

    def check_for_requirement(requirement, constructor_hash)
      if self.send requirement[:name]
        raise OptionError, instance_eval(&requirement[:message]) unless self.instance_exec(constructor_hash,&requirement[:check])
      end
    end
    private :check_for_requirement

    def process(constructor_hash)
      if constructor_hash.has_key?(self.name)
        REQUIREMENTS.each do |requirement|
          check_for_requirement(requirement, constructor_hash)
        end
        constructor_hash[self.name]
      else
        check_for_requirement(REQUIRED_REQUIREMENT, constructor_hash)
        self.default
      end
    end
  end
end
