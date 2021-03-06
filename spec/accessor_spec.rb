require 'spec_helper'

describe 'hash field access: ' do

  describe 'get: ' do
    it 'should access field' do
      doc = { 'foo' => 'bar' }

      Accessor.new.get(doc, 'foo').should == 'bar'
    end

    it 'should access nested field' do
      doc = { 'foo' => { 'fuu' => 'baz' } }

      Accessor.new.get(doc, 'foo.fuu').should == 'baz'
    end

    it 'should escape dot as special character' do
      doc = { 'foo.fuu' => 'bar' }

      Accessor.new.get(doc, 'foo\.fuu').should == 'bar'
    end
  end

  describe 'set: ' do
    it 'should set field' do
      doc = {}

      Accessor.new.set(doc, 'foo', 'bar')

      doc['foo'].should == 'bar'
    end

    it 'should set nested field' do
      doc = {}

      Accessor.new.set(doc, 'foo.fii.fuu', 'bar')

      doc['foo']['fii']['fuu'].should == 'bar'
    end

    it 'should preserve existing fields when setting nested field' do
      doc = { 'foo' => { 'fee' => {}, 'fii' => 'bir' }}

      Accessor.new.set(doc, 'foo.fee.fuu', 'bar')

      doc['foo']['fii'].should == 'bir'
    end

    it 'should escape dot as special character' do
      doc = { 'foo' => 'bar' }

      Accessor.new.set(doc, 'foo\.fuu', 'baz')

      doc.should == { 'foo' => 'bar', 'foo.fuu' => 'baz' }
    end
  end

  describe 'delete: ' do
    it 'should delete field' do
      doc = { 'foo' => 'bar' }

      Accessor.new.delete doc, 'foo'

      doc.should == {}
    end

    it 'should delete nested field' do
      doc = { 'foo' => { 'fee' => { 'fii' => 'wii', 'fuu' => 'wuu' }}}

      Accessor.new.delete doc, 'foo.fee.fii'

      doc['foo']['fee'].should == { 'fuu' => 'wuu' }
    end

    it 'should escape dot as special character' do
      doc = { 'foo.fuu' => 'bar' }

      Accessor.new.delete(doc, 'foo\.fuu')

      doc.should == {}
    end
  end

  describe 'accessor splitting: ' do

    it 'should split accessor on dot' do
      Accessor.new.send(:split, 'foo.bar.baz').should == ['foo', 'bar', 'baz']
    end

    it 'should escape dot' do
      Accessor.new.send(:split, 'foo\.bar').should == ['foo.bar']
    end

    it 'accessor with escaped dot and seperating dot' do
      Accessor.new.send(:split, 'foo\.bar.baz').should == ['foo.bar', 'baz']
    end

    it 'accessor with backslash' do
      Accessor.new.send(:split, 'foo\\\\bar').should == ['foo\bar']
    end

    it 'nothing to split' do
      Accessor.new.send(:split, 'foo').should == ['foo']
    end
  end
end
