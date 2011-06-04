require 'helper'
describe 'integration' do
  describe 'Class' do
    describe 'constructable' do
      it 'should define attr_accessors' do
        klass = Class.new
        klass.constructable(:foo)
        assert_respond_to klass.new, :foo
        assert_respond_to klass.new, :foo=
      end

      it 'should assign values found in the constructer hash' do
        klass = Class.new
        klass.constructable(:foo)
        instance = klass.new(foo: :bar)
        assert_equal :bar, instance.foo
      end

      it 'should work with inheritance' do
        klass = Class.new
        klass.constructable(:bar)
        inherited_klass = Class.new(klass)
        instance = inherited_klass.new(bar: 1)
        assert_equal 1, instance.bar
      end

      it 'should be possible to make attributes required' do
        klass = Class.new
        klass.constructable([:bar, :required])
        assert_raises ArgumentError do
          klass.new
        end
      end

      it 'should not break the initalize behaviour' do
        klass = Class.new
        klass.constructable([:bar, :required])
        klass.class_eval do
          def initialize
            self.bar = 20
          end
        end
        instance = klass.new(bar: 5)
        assert_equal 20, instance.bar
      end
    end
  end
end
