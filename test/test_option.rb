require 'helper'
include Constructable
describe 'Option' do
  describe 'name' do
    it 'returns the name' do
      option = Option.new(:option)
      assert_equal :option, option.name
    end
  end

  describe 'ivar_symbol' do
    it 'should return @<name>' do
      option = Option.new(:foo)
      assert_equal :@foo, option.ivar_symbol
    end
  end

  describe 'process' do
    it 'should raise nothing if no options are specified' do
      option = Option.new(:foo)
      assert_equal 'bar', option.process({foo: 'bar'})
    end

    describe 'required option' do
      it 'should raise an OptionError if required is set to true' do
        option = Option.new(:foo, required: true)
        begin
          option.process(bar: 'blab')
        rescue Exception => e
          assert OptionError === e
          assert_equal ':foo is a required option', e.message
        else
          assert false, 'OptionError was not raised'
        end
      end
    end

    describe 'validator' do
      it 'should raise an OptionError if the validator doesn\'t pass' do
        option = Option.new(:foo, validate: ->(number) { number < 5 })
        begin
          option.process(foo: 6)
        rescue Exception => e
          assert OptionError === e, "[#{e.class},#{e.message}] was not expected"
          assert_equal ':foo did not pass validation', e.message
        else
          assert false, 'OptionError was not raised'
        end
      end
    end

    describe 'type check' do
      it 'should raise an OptionError if the value has not the wanted type' do
        option = Option.new(:foo, type: Integer)
        begin
          option.process(foo: 'notanumber')
        rescue Exception => e
          assert OptionError === e, "[#{e.class},#{e.message}] was not expected"
          assert_equal ':foo is not of type Integer', e.message
        else
          assert false, 'OptionError was not raised'
        end
      end
    end

    describe 'default value' do
      it 'should be possible to provide a default value' do
        option = Option.new(:foo, default: :bar)
        assert_equal :bar, option.process({})
      end
    end
  end

  describe 'permission' do
    it 'should detect accessible options' do
      option = Option.new( :readable_and_writable, accessible: true)
      assert_equal [:reader, :writer], option.permissions
    end

    it 'should not be public by default' do
      option = Option.new( :test_default)
      assert_equal [] , option.permissions
    end

    [:writable, :readable].each do |perm|
      it "should be definable for #{perm}" do
        option = Option.new(:"#{perm}_option", perm => true)
        assert_equal [(perm[0..3] + 'er').to_sym], option.permissions
      end
    end
  end
end
