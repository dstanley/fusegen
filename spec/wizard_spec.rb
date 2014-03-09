require 'test_helper'

require FUSEGEN_ROOT + '/lib/fusegen/generator.rb'

require 'pp'

describe "Generate amq-wizard test" do
   include TempDirectorySupport

   # Done once on init
   before(:all) do
      @options = { 
         :index => SPEC_ROOT + '/resources/cache', 
         :name => "mvn-wizard",
         :groupid => "com.fusegen.test", 
         :artifactid => "mvn-wizard",
         :fuseversion => "60024",
         :fabrichost => "localhost",
         :packaging => "bundle",
         :projectversion => "1.0-SNAPSHOT",
         :debug => true
         
       }
   end

   
   context "test wizard project" do
         new_tmp_directory('tmp')

         it "should generate wizard project correctly" do
            puts "Testing wizard project generator"
            generator = Generator.new
            template = generator.find_quickstart @options            
            template["category"].should == "test"
            @options[:category] = template["category"]
            @options[:gitbase] = FUSEGEN_ROOT
            @options[:appendbaseuri] = true
            generator.new_project(@options)
            
         end
    end
   
end
