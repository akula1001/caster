require 'spec_helper'

describe 'add field: ' do
  before do
    @doc1 = @foobar.save_doc({})
    @doc2 = @foobar.save_doc({})
    @doc3 = @foobar.save_doc({})
  end

  it "should add name and occupation fields to all created docs" do
    over 'foobar/foobar/all' do
      add 'name', 'atilla'
      add 'occupation', 'warrior'
    end

    [@doc1, @doc2, @doc3].each do |doc|
      @foobar.get(doc['id'])['name'].should == 'atilla'
      @foobar.get(doc['id'])['occupation'].should == 'warrior'
    end
  end
end

describe 'add nested field: ' do
  before do
    @doc = @foobar.save_doc({})
  end

  it 'should add name as doc["account"]["profile"]["name"]' do
    over 'foobar/foobar/all' do
      add 'profile.name', 'atilla'
    end

    @foobar.get(@doc['id'])['profile']['name'].should == 'atilla'
  end
end
