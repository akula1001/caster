require 'spec_helper'

describe 'remove field: ' do
  before do
    @doc1 = @foobar.save_doc({ "type" => "foo", "name" => "carman", "state" => "on" })
    @doc2 = @foobar.save_doc({ "type" => "foo", "name" => "fifo" })
    @doc3 = @foobar.save_doc({ "type" => "foo" })

    over 'foobar/foobar/all_foo' do
      remove 'name'
    end
  end

  it "should remove name field from all docs" do
    [@doc1, @doc2, @doc3].each do |doc|
      @foobar.get(doc['id'])['name'].should == nil
    end
  end
end
