require 'helper'
describe 'Constructor' do
  before do
    @klass = Class.new
  end

  describe 'define_attributes' do
    it 'defines public setters validating like in the constructor' do
      @klass.constructable [:integer, validate_type: Integer, writable: true]
      instance = @klass.new
      assert_raises AttributeError do
        instance.integer = 6.6
      end
    end

    it 'allows redefining getters ' do
      @klass.class_eval { define_method(:integer){ 1 } }
      @klass.constructable [:integer, validate_type: Integer, readable: true]
      instance = @klass.new(integer: 2)
      assert_equal 1, instance.integer
    end

    it 'allows redefining setters ' do
      @klass.class_eval { def integer=(foo);@integer = 1;end }
      @klass.constructable [:integer, validate_type: Integer, readable: true]
      instance = @klass.new(integer: 4)
      instance.integer = 5
      assert_equal 1, instance.integer
    end
  end

  describe 'Class#constructable_attributes' do
    it 'returns the attribute matching the symbol' do
      @klass.constructable :foo, :bar
      instance = @klass.new(foo: 6)
      assert_equal({ foo: 6 }, instance.constructable_attributes)
    end
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

  describe 'module support' do
    before do
      module Foo
        constructable [:foo, readable: true]
      end
    end

    it 'allows cosntructing classes after including the module' do
      class Bar
        include Foo
      end
      bar = Bar.new(foo: 'foo')
      assert_equal 'foo', bar.foo
    end
  end
end
