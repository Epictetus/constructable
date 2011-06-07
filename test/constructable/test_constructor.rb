require 'helper'
describe 'Constructor' do
  before do
    @klass = Class.new
  end
  describe 'permission' do
    it 'should allow writable attributes' do
      @klass.constructable [:writable_attribute, writable: true]
      instance = @klass.new
      instance.writable_attribute = "hello"
      assert_equal "hello", instance.instance_variable_get(:@writable_attribute)
    end

    it 'should allow readable attributes' do
      @klass.constructable [:readable_attribute, readable: true]
      instance = @klass.new
      instance.instance_variable_set(:@readable_attribute, "hello")
      assert_equal "hello", instance.readable_attribute
    end

    it 'should allow accessible attributes' do
      @klass.constructable [:accessible_attribute, accessible: true]
      instance = @klass.new
      instance.accessible_attribute = 'hello'
      assert_equal 'hello', instance.accessible_attribute
    end
  end
end
