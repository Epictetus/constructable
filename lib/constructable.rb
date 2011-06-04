require 'constructable/constructor'
require 'constructable/core_ext'
module Constructable
  def constructable(*args)
    @__constructor ||= Constructor.new(self)
    @__constructor.define_constructors(args)
  end
end
