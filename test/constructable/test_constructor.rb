require 'helper'
describe 'Constructor' do
  before do
    @klass = Class.new
    @module = Module.new
  end

  describe 'define_attributes' do
    it 'should define attr_accessors' do
      klass = Class.new
      klass.constructable(:foo, accessible: true)
      assert_respond_to klass.new, :foo
      assert_respond_to klass.new, :foo=
    end

    it 'defines public setters validating like in the constructor' do
      @klass.constructable :integer, validate_type: Integer, writable: true
      instance = @klass.new
      assert_raises AttributeError do
        instance.integer = 6.6
      end
    end

    describe 'redefining' do
      describe 'constructing a class will call redefined setters' do
        it 'calls the redefined setters' do
          @klass.constructable :bacon, readable: true
          @klass.class_eval { private; def bacon=(value);super(:zomg_bacon);end }
          instance = @klass.new(bacon: :no_bacon)
          assert_equal :zomg_bacon, instance.bacon
        end
      end

      describe 'class' do
        it 'getters ' do
          @klass.constructable :integer, validate_type: Integer, accessible: true
          @klass.class_eval { define_method(:integer){ 1 } }
          instance = @klass.new(integer: 2)
          assert_equal 1, instance.integer
        end

        it 'setters ' do
          @klass.constructable :integer, validate_type: Integer, accessible: true
          @klass.class_eval { def integer=(foo);@integer = 1;end }
          instance = @klass.new(integer: 4)
          instance.integer = 5
          assert_equal 1, instance.integer
        end
      end

      describe 'module' do
        before do
          @module.constructable :integer, validate_type: Integer, accessible: true
        end

        it 'getters ' do
          @module.module_eval { def integer;1;end }
          @klass.send :include,@module
          instance = @klass.new(integer: 2)
          assert_equal 1, instance.integer
        end

        it 'setters ' do
          @module.module_eval { def integer=(foo);@integer = 1;end }
          @klass.send :include,@module
          instance = @klass.new(integer: 4)
          instance.integer = 5
          assert_equal 1, instance.integer
        end

        it 'also works for multiple inclusion' do
          @module.module_eval { def integer=(foo);@integer = 1;end }
          other_module = Module.new
          other_module.send :include, @module
          @klass.send :include, other_module
          instance = @klass.new(integer: 4)
          instance.integer = 5
          assert_equal 1, instance.integer
        end

      end

      describe 'allows to super to the generated method' do
        it 'gets' do
          @klass.constructable :integer, validate_type: Integer, accessible: true
          @klass.class_eval { def integer; super ;end }
          instance = @klass.new(integer: 2)
          assert_equal 2, instance.integer
        end

        it 'sets' do
          @klass.constructable :integer, validate_type: Integer, accessible: true
          @klass.class_eval { def integer=(value); super ;end }
          instance = @klass.new(integer: 2)
          assert_raises Constructable::AttributeError do
            instance.integer = :not_an_integer
          end
        end

        it 'sets for private setters/getters' do
          @klass.constructable :integer, validate_type: Integer, readable: true
          @klass.class_eval { private; def integer=(value); super(value.to_i) ;end }
          instance = @klass.new(integer: '5')
          assert_equal 5, instance.integer
        end
      end
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
      @klass.constructable :writable_attribute, writable: true
      instance = @klass.new
      instance.writable_attribute = "hello"
      assert_equal "hello", instance.instance_variable_get(:@writable_attribute)
    end

    it 'should allow readable attributes' do
      @klass.constructable :readable_attribute, readable: true
      instance = @klass.new
      instance.instance_variable_set(:@readable_attribute, "hello")
      assert_equal "hello", instance.readable_attribute
    end

    it 'should allow accessible attributes' do
      @klass.constructable :accessible_attribute, accessible: true
      instance = @klass.new
      instance.accessible_attribute = 'hello'
      assert_equal 'hello', instance.accessible_attribute
    end
  end

  describe 'module support' do
    before do
      @foo = Module.new do
        constructable :foo, readable: true
      end
    end

    it 'allows cosntructing classes after including the module' do
      @bar = Class.new
      @bar.send :include, @foo

      bar = @bar.new(foo: 'foo')
      assert_equal 'foo', bar.foo
    end

    describe 'shared setup' do

      before do
        @bar = Module.new
        @bar.send :include, @foo

        @baz = Class.new
        @baz.send :include, @bar
      end

      it 'works for multiple inclusion' do
        baz = @baz.new(foo: 'foo')
        assert_equal 'foo', baz.foo
      end

      it 'always sets the @constructor ivar' do
        assert_equal @foo.instance_variable_get(:@constructor), @baz.instance_variable_get(:@constructor)
      end

    end
  end
end
