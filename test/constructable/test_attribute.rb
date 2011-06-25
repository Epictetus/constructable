require 'helper'
include Constructable
describe 'Attribute' do

  describe 'name' do
    it 'returns the name' do
      attribute = Attribute.new(:attribute)
      assert_equal :attribute, attribute.name
    end
  end

  describe 'ivar_symbol' do
    it 'should return @<name>' do
      attribute = Attribute.new(:foo)
      assert_equal :@foo, attribute.ivar_symbol
    end
  end

  describe 'process' do
    it 'intepretes nil but not false as undefined' do
      attribute = Attribute.new(:foo, default: ->{true})
      assert_equal false, attribute.process(false)
    end

    it 'should raise nothing if no attributes are specified' do
      attribute = Attribute.new(:foo)
      assert_equal 'bar', attribute.process('bar')
    end

    describe 'required attribute' do
      it 'should raise an AttributeError if required is set to true' do
        attribute = Attribute.new(:foo, required: true)
        begin
          attribute.process(nil)
        rescue Exception => e
          assert AttributeError === e
          assert_equal ':foo is a required attribute', e.message
        else
          assert false, 'AttributeError was not raised'
        end
      end
    end

    describe 'attribute is neither required nor provided' do
      it 'does not check for further requirements' do
        attribute = Attribute.new(:foo, validate_type: Integer)
        refute_raises do
          attribute.process(nil)
        end
      end
    end

    describe 'default value' do
      it 'should be possible to provide a default value' do
        attribute = Attribute.new(:foo, default: ->{ :bar })
        assert_equal :bar, attribute.process(nil)
      end
    end

    describe 'convert value' do
      it 'is possible to define a converter(proc) which converts attribute values' do
        attribute = Attribute.new(:number, converter: ->(value) { value.to_i })
        assert_equal 5, attribute.process('5')
      end
    end
  end

  describe 'permission' do
    it 'should detect accessible attributes' do
      attribute = Attribute.new( :readable_and_writable, accessible: true)
      assert_equal true, attribute.readable
      assert_equal true, attribute.writable
    end
  end
end
