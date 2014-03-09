require 'test_helper'

require FUSEGEN_ROOT + '/lib/fusegen/generator.rb'

require 'pp'




describe "Cache tests" do
  it "test repo list" do
    generator = Generator.new
    config = generator.load_file(SPEC_ROOT + '/resources/cache/repos')
    config.size.should == 2
    config["repo1"].size.should == 1
    config["repo2"].size.should == 1 
  end
  
  it "test local quickstart list" do
    generator = Generator.new
    options = { :index => SPEC_ROOT + '/resources/cache' }      
    quickstarts = generator.get_quickstarts  options
    quickstarts.size.should == 3
    quickstarts["amq"].size.should == 3
    quickstarts["fuse"].size.should == 3
    quickstarts["test"].size.should == 2
  end
  
  it "find a quickstart" do
    generator = Generator.new
    options = { :index => SPEC_ROOT + '/resources/cache', :name => "amq-consumer" }      
    template = generator.find_quickstart options
    template["name"].should == "amq-consumer"
  end
  
end





