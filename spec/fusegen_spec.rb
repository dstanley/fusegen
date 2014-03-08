require 'test_helper'

require FUSEGEN_ROOT + '/lib/fusegen/generator.rb'

require 'pp'

module TempDirectorySupport
  def self.included(base)
    base.extend(self)
  end

  def new_tmp_directory(directory)
    before do
      @pwd = Dir.pwd
      @tmp_dir = File.join(File.dirname(__FILE__), directory)
      FileUtils.mkdir_p(@tmp_dir)
      Dir.chdir(@tmp_dir)
    end

    after do
      Dir.chdir(@pwd)
      FileUtils.rm_rf(@tmp_dir)
    end
  end
end


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
    options = { :index => SPEC_ROOT + '/resources/cache/repos' }      
    quickstarts = generator.get_quickstarts  options
    quickstarts.size.should == 3
    quickstarts["amq"].size.should == 3
    quickstarts["fuse"].size.should == 3
    quickstarts["wmq"].size.should == 1
  end
  
  it "find a quickstart" do
    generator = Generator.new
    options = { :index => SPEC_ROOT + '/resources/cache/repos', :name => "amq-consumer" }      
    template = generator.find_quickstart options
    template["name"].should == "amq-consumer"
  end
  


end


describe "Generate amq-consumer test" do
   include TempDirectorySupport
   
   context "test quickstart info" do
        new_tmp_directory('tmp')
        
        it "find quickstart info" do
           puts "Testing find quickstart readme"
           generator = Generator.new
           options = { 
              :index => SPEC_ROOT + '/resources/cache/repos', 
              :name => "amq-consumer",
              :groupid => "com.fusegen.test", 
              :artifactid => "amq-consumer",
              :fuseversion => "60024",
              :fabrichost => "localhost",
              :packaging => "bundle",
              :projectversion => "1.0-SNAPSHOT",
              :debug => true
           }
           result = generator.qs_info options, ["amq-consumer"]
           result.should == true
        end
   end
end


describe "Generate amq-consumer test" do
   include TempDirectorySupport

   # Done once on init
   before(:all) do
      @options = { 
         :index => SPEC_ROOT + '/resources/cache/repos', 
         :name => "amq-consumer",
         :groupid => "com.fusegen.test", 
         :artifactid => "amq-consumer",
         :fuseversion => "60024",
         :fabrichost => "localhost",
         :packaging => "bundle",
         :projectversion => "1.0-SNAPSHOT",
         :debug => true
       }
   end


   context "test new project" do
       new_tmp_directory('tmp')

       it "should generate project correctly" do
         puts "Testing project generator"
         generator = Generator.new
         
         template = generator.find_quickstart @options
         template["category"].should == "amq"
         @options[:category] = template["category"]
         generator.new_project(@options)
         
         expected = [ "amq-consumer/src/main/java/com/fusegen/test/Consumer.java",
              "amq-consumer/src/main/java/com/fusegen/test/CommandLineSupport.java",
              "amq-consumer/README.md",
              "amq-consumer/pom.xml",
              "amq-consumer/src/main/resources/log4j.xml"]
         
         Dir.glob("amq-consumer/**/*.*").each do |file|
           check = expected.include? file
           check.should == true
         end
         puts "Completed.."
       end
    end
  
end