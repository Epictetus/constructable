module Constructable
  class Option
    OPTIONS = [:writable, :readable, :accessible, :required, :validate, :default, :type]
    attr_accessor *OPTIONS, :name

    REQUIREMENTS = [
      [:required, proc {":#{self.name} is a required option"}, ->(hash) { hash.has_key?(self.name) }],
      [:validate, proc {":#{self.name} did not pass validation"}, ->(hash) { self.validate.call(hash[self.name])}],
      [:type, proc {":#{self.name} is not of type #{self.type}"}, ->(hash) { self.type === hash[self.name] }]
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

    def process(constructor_hash)
      REQUIREMENTS.each do |requirement|
        if self.send requirement[0]
          raise OptionError, instance_eval(&requirement[1]) unless self.instance_exec(constructor_hash,&requirement[2])
        end
      end
      constructor_hash.has_key?(self.name) ? constructor_hash[self.name] : self.default
    end
  end
end
