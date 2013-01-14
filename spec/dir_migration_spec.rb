require 'spec_helper'
require 'caster/migrator'

describe 'migrate specific database inside a directory of assorted cast files: ' do

  before do
    @doc = @foobar.save_doc({ 'type' => 'foo' })
    @res = "#{File.dirname(__FILE__)}/res/multiple_migrations"
    @migrator = Migrator.new MetadataDocument.new
  end

  it "should run migrations 000, 0001, 001 for foobar" do
    @migrator.migrate_in_dir @res, 'foobar'

    @foobar.get(@doc['id'])['name'].should == 'atilla'
    @foobar.get(@doc['id'])['class'].should == 'hun'
    @foobar.get(@doc['id'])['title'].should == 'warrior'
  end

  it "should update revision" do
    @migrator.migrate_in_dir @res, 'foobar'

    @foobar.get('caster_foobar')['version'].should == '001'
    @foobar.get('caster_foobar')['type'].should == 'caster_metadoc'
  end

  it "should not run migration 000 for foobar" do
    @foobar.save_doc({
         '_id' => 'caster_foobar',
         'type' => 'caster_metadoc',
         'version' => '000'
    })

    @migrator.migrate_in_dir @res, 'foobar'

    @foobar.get(@doc['id'])['name'].should == nil
    @foobar.get(@doc['id'])['class'].should == 'hun'
    @foobar.get(@doc['id'])['title'].should == 'warrior'
  end

  it "should run migrations for foobar upto 0001 only" do
    @migrator.migrate_in_dir @res, 'foobar', '0001'

    @foobar.get(@doc['id'])['name'].should == 'atilla'
    @foobar.get(@doc['id'])['class'].should == 'hun'
    @foobar.get(@doc['id'])['title'].should == nil
  end

  it "should not run fuubar migrations" do
    @migrator.migrate_in_dir @res, 'foobar'

    @foobar.get(@doc['id'])['oops'].should == nil
  end
end

describe 'migrate all cast scripts inside a directory to the latest version: ' do

  before do
    @fuubar = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/fuubar"
    @fuubar.save_doc({
         '_id' => '_design/fuubar',
         :views => {
             :all_fuu => {
                 :map => "function(doc) { if (doc.type == 'fuu') emit (doc._id, doc); }"
             }
         }
    })

    @foo_doc = @foobar.save_doc({ 'type' => 'foo' })
    @fuu_doc = @fuubar.save_doc({ 'type' => 'fuu' })

    @res = "#{File.dirname(__FILE__)}/res/multiple_migrations"

    @migrator = Migrator.new MetadataDocument.new
  end

  it "should run all migrations 000, 0001, 001 for foobar and 000 for fuubar" do
    @migrator.migrate_in_dir @res

    @foobar.get(@foo_doc['id'])['name'].should == 'atilla'
    @foobar.get(@foo_doc['id'])['class'].should == 'hun'
    @foobar.get(@foo_doc['id'])['title'].should == 'warrior'
    @fuubar.get(@fuu_doc['id'])['name'].should == 'genghis'
  end

  it "should update revision" do
    @migrator.migrate_in_dir @res

    @foobar.get('caster_foobar')['version'].should == '001'
    @fuubar.get('caster_fuubar')['version'].should == '000'
  end

  it "should not run migration 000 for foobar; should run for fuubar" do
    @foobar.save_doc({
         '_id' => 'caster_foobar',
         'type' => 'caster_metadoc',
         'version' => '000'
    })

    @migrator.migrate_in_dir @res

    @foobar.get(@foo_doc['id'])['name'].should == nil
    @foobar.get(@foo_doc['id'])['class'].should == 'hun'
    @foobar.get(@foo_doc['id'])['title'].should == 'warrior'

    @fuubar.get(@fuu_doc['id'])['name'].should == 'genghis'
  end

  after do
    @fuubar.delete!
  end
end

describe "store metadata doc in it's own database: " do

  before do
    Caster.config[:metadata][:database] = 'caster_metadb'

    @doc = @foobar.save_doc({ 'type' => 'foo' })
    @res = "#{File.dirname(__FILE__)}/res/multiple_migrations"
    @migrator = Migrator.new MetadataDocument.new
  end

  it "should update revision" do
    @migrator.migrate_in_dir @res, 'foobar'

    @metadb = CouchRest.database! "http://#{Caster.config[:host]}:#{Caster.config[:port]}/caster_metadb"
    @metadb.get('caster_foobar')['version'].should == '001'
    @metadb.get('caster_foobar')['type'].should == 'caster_metadoc'
  end

  after do
    @metadb.delete!
    Caster.config[:metadata][:database] = nil
  end
end
