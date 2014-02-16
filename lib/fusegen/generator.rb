require 'thor'

class Generator < Thor
  include Thor::Actions

  attr_accessor :versions

  desc "generate", "generate new project"
  def generate(global_options,options,args)
  
    begin  
      say_task "Creating " + options[:name] 
      create_project options  
    rescue Exception => e  
      pp global_options
      pp options
      pp args
      puts e.message  
      puts e.backtrace
    end
  end
  
  def self.source_root
      File.dirname(__FILE__)
  end
    
private

  def initialize
    super
    
    @versions = { "60"=> { "camel"=>"2.10.0.redhat-", "activemq"=>"5.8.0.redhat-", 
                           "cxf"=>"2.6.0.redhat-", "spring"=>"3.1.3.RELEASE",
                           "karaf"=>"2.3.0.redhat-" }, 
                  "61"=> { "camel"=>"2.12.0.redhat-", "activemq"=>"5.9.0.redhat-", 
                           "cxf"=>"2.7.0.redhat-", "spring"=>"3.2.3.RELEASE",
                           "karaf"=>"2.3.0.redhat-" } 
    }
                
  end
  
  def create_project(options)
      
      #begin
      base_path = options[:groupid].gsub('.', '/')
        
      # Download manifest
      copy_from_github 'manifest.yml', 'manifest.yml', options
      
      project = load_file 'manifest.yml', options
  
      if project.size > 0
        
        project["copies"].each do |source, destination| 
          destination.gsub! '@base_path',base_path
          copy_from_github source, destination, options
        end
      
        project["subs"].each do |subs|      
          subs[1].each do |sub| 
             file = options[:name] + '/' + subs[0].dup
             file.gsub! '@base_path',base_path
             subvalue = get_substitution_value(sub, options) 
             regex = Regexp.new /#{sub}/
             gsub_file file, regex, subvalue          
          end
        end
        
        remove_file options[:name] + '/manifest.yml'   
      else
        say_error "Quickstart '" + options[:name] + "' is not valid"
      end
      
  end
  
 
  def say_task(name); say "\033[1m\033[32m" + "task".rjust(10) + "\033[0m" + "  #{name} .." end
  def say_warn(name); say "\033[1m\033[36m" + "warn".rjust(10) + "\033[0m" + "  #{name}" end
  def say_error(name); say "\033[1m\033[31m" + "error".rjust(10) + "\033[0m" + "  #{name}" end
  

  def source_paths
     [File.join(Dir.pwd, "templates")] + super
  end
  
  def copy_from_github(source, destination, options = {})
    base = 'https://raw.github.com/dstanley/fusegen-templates/master/archetypes/'
    base = options[:gitbase] unless options[:gitbase].nil?    
    base = base  + options[:category] + '/' + options[:name] + '/'
    
    begin
       #remove_file destination       
       get base + source, options[:name] + '/' + destination
    rescue OpenURI::HTTPError
       say_error "Unable to download " + base + source
    end    
  end
  
  def load_file(file, options={})
    begin
      cfg = {}
      path = options[:name] + '/' + file
      cfg = YAML.load_file(path)
    rescue Exception => e        
    end
    cfg
  end
  
  
  def get_substitution_value(keyword, options={})
    case keyword
      when "@project_version" 
        options[:projectversion]
      when "@package" 
        options[:groupid]
      when "@package_reverse" 
        options[:groupid].split(".").reverse.join(".")
      when "@group_id"
        options[:groupid]
      when "@artifact_id"
        options[:artifactid]      
      when "@packaging"
        options[:packaging]
      when "@project_version"
        options[:projectversion]      
      when "@name"
        options[:name]  
      when "@camel_version"
        get_version(options[:fuseversion],"camel")
      when "@activemq_version"
        get_version(options[:fuseversion],"activemq")
      when "@cxf_version"
        get_version(options[:fuseversion],"cxf")
      when "@smx_version"
        get_version(options[:fuseversion],"smx")
      when "@karaf_version"
        get_version(options[:fuseversion],"karaf")
      when "@spring_version"
        get_version(options[:fuseversion],"spring")
      when "@fabric_host" 
        "@" + options[:fabrichost]
      else
        keyword 
      end
  end
  
  def get_version(project_version, component) 
    @versions[project_version[0..1]][component] + project_version
  end
  
  
end
