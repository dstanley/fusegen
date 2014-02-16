require 'thor'

class Generator < Thor
  include Thor::Actions

  desc "generate", "generate project"
  def generate(global_options,options,args)
    init
    
    #pp global_options
    #pp options
    #pp args
    
    say_task "Creating " + options[:name] 
    
    create_project global_options
    
  end
  
  def self.source_root
      File.dirname(__FILE__)
  end
    
private

  def init
    @versions = { "60"=> { "camel"=>"2.10.0.redhat-", "activemq"=>"5.8.0.redhat-" } , 
                  "61"=> { "camel"=>"2.12.0.redhat-", "activemq"=>"5.9.0.redhat-" } }
  end
  
  def create_project(options)
      
      #begin
      base_path = options[:groupid].gsub('.', '/')
      
      copy_from_github 'camel-base/pom.tmpl', 'testcase/pom.xml', options
      gsub_file 'testcase/pom.xml', /@project_version/, options[:projectversion]
      gsub_file 'testcase/pom.xml', /@group_id/, options[:groupid]
      gsub_file 'testcase/pom.xml', /@artifact_id/, options[:artifactid]
      gsub_file 'testcase/pom.xml', /@packaging/, options[:packaging]
      gsub_file 'testcase/pom.xml', /@project_version/, options[:projectversion]
      gsub_file 'testcase/pom.xml', /@name/, options[:name]
      gsub_file 'testcase/pom.xml', /@fuse_version/, get_version(options[:fuseversion],"camel")
      gsub_file 'testcase/pom.xml', /@fabric_host/, '@' + options[:fabrichost]
      
      copy_from_github 'camel-base/src/main/resources/log4j.properties', 'testcase/src/main/resources/log4j.properties', options
      copy_from_github 'camel-base/src/main/resources/OSGI-INF/blueprint/blueprint.xml', 'testcase/src/main/resources/OSGI-INF/blueprint/blueprint.xml', options
      copy_from_github 'camel-base/src/main/java/org/fusesource/support/Hello.java', 'testcase/src/main/java/' + base_path + '/Hello.java', options
      copy_from_github 'camel-base/src/main/java/org/fusesource/support/HelloBean.java', 'testcase/src/main/java/' + base_path + '/HelloBean.java', options 
      copy_from_github 'camel-base/src/test/java/org/fusesource/support/RouteTest.java', 'testcase/src/test/java/' + base_path + '/RouteTest.java', options 
      
      gsub_file 'testcase/src/main/resources/OSGI-INF/blueprint/blueprint.xml' , /@package/, options[:groupid]
      gsub_file 'testcase/src/main/java/' + base_path + '/Hello.java' , /@package/, options[:groupid]
      gsub_file 'testcase/src/main/java/' + base_path + '/HelloBean.java' , /@package/, options[:groupid]
      gsub_file 'testcase/src/test/java/' + base_path + '/RouteTest.java' , /@package/, options[:groupid]
      #rescue
        
      #end
  end
  
 
  def say_task(name); say "\033[1m\033[36m" + "task".rjust(10) + "\033[0m" + "  #{name} ..." end
  def say_warn(name); say "\033[1m\033[36m" + "warn".rjust(10) + "\033[0m" + "  #{name} ..." end
  

  def source_paths
     [File.join(Dir.pwd, "templates")] + super
  end
  
  def copy_from_github(source, destination, options = {})
    base = 'https://raw.github.com/dstanley/fusegen-templates/master/archetypes/'
    base = options[:gitbase] unless options[:gitbase].nil?
    
    base = base  + options[:cmd] + '/'
    
    begin
       #remove_file destination       
       get base + source, destination
    rescue OpenURI::HTTPError
       say_warn "Unable to download #{source} from uri #{base}"
    end    
  end
  
  def get_version(project_version, component) 
    @versions[project_version[0..1]][component] + project_version
  end
    
  
  
end
