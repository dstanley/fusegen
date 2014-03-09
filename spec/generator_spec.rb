require 'test_helper'

require FUSEGEN_ROOT + '/lib/fusegen/generator.rb'

require 'pp'



describe "Generate amq-consumer test" do
   include TempDirectorySupport

   # Done once on init
   before(:all) do
      @options = { 
         :index => SPEC_ROOT + '/resources/cache', 
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
    
    context "test quickstart info" do
         new_tmp_directory('tmp')

         it "find quickstart info" do
            puts "Testing find quickstart readme"
            generator = Generator.new
            result = generator.qs_info @options, ["amq-consumer"]
            result.should == true
         end
    end
  
end


