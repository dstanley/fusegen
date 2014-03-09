require 'rubygems'
require 'thor'
require 'yaml'


class Generator < Thor

  module Util
    
    def initialize
      super
      @versions = { 
        "60"=> { "camel"=>"2.10.0.redhat-", "activemq"=>"5.8.0.redhat-", 
                 "cxf"=>"2.6.0.redhat-", "spring"=>"3.1.3.RELEASE",
                 "karaf"=>"2.3.0.redhat-" }, 
                 
        "61"=> { "camel"=>"2.12.0.redhat-", "activemq"=>"5.9.0.redhat-", 
                 "cxf"=>"2.7.0.redhat-", "spring"=>"3.2.3.RELEASE",
                 "karaf"=>"2.3.0.redhat-" } 
      }            
    end
    

    def copy_from_repo(source, destination, options = {})
      
      base = options[:gitbase] unless options[:gitbase].nil?    
      prefix = ""

      # true when creating a new project
      if options[:category] != "none" && options[:name]
        base = base  + options[:category] + '/' + options[:name] + '/'
        prefix = options[:name] + '/'
      end

      begin
         #remove_file destination  
         if base =~ /http/
           get base + source, prefix + destination, options
         else
           copy_file base + source, prefix + destination, options
         end
      rescue Exception => e 
         say_error "Unable to copy, base: '" + base.to_s + "' source: '" + source.to_s + "'"
         if options[:debug] 
             puts e.message  
             puts e.backtrace
         end         
      end    
    end

    def load_file(file, options={})
      begin
        cfg = {}
        if file =~ /~/
          file[0] = ''
          file = File.expand_path('~') + file
        end

        if options[:name]
          file = options[:name] + '/' + file
        end
        cfg = YAML.load_file(file)
      rescue Exception => e  
        puts e.message
        puts e.backtrace      
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
          get_version(options[:fuseversion],"spring",false)
        when "@fabric_host" 
          "@" + options[:fabrichost]
        else
          keyword 
        end
    end
    
    def get_quickstarts(options={}) 
      
      index_root = "~/.fusegen"
      
      if options[:index]
        index_root = options[:index]
      end
      
      repos = load_file  index_root + "/repos"

      
      quickstarts = {}
      repos.each do |key, value|

        # load the index
        index = load_file index_root + "/#{value["meta"]}/index"

        meta = index["meta"]
        
        # refresh index if its expired
        if meta && meta["expires"] < Time.now
          options[:gitbase] = meta["baseuri"]
          do_repo_add meta["baseuri"], options
          index = load_file index_root + "/#{value["meta"]}/index"
        end
        
        index["quickstarts"].each do |category, meta|
           meta.each do |template|
              template["repo"] = value["meta"]
              template["baseuri"] = index["meta"]["baseuri"]       
              template["category"] = category      
                   
              if quickstarts[category].nil? then quickstarts[category] = []; end
              quickstarts[category] << template
           end
        end
      end
      quickstarts
    end
    
    def find_quickstart(options)
       if options[:debug]
          say_debug "find quickstart " + options[:name] 
       end
      
       # load all know quickstarts from cache
       quickstarts = get_quickstarts options
       candidates = {}
       quickstarts.each do |category, meta|
           meta.each do |template|

             if options[:debug]
                 say_debug "found " + template["name"]
             end
             
             # find a match by quickstart name
             if template["name"] == options[:name]
                 candidates[template["repo"]] = template
             end
          end
       end
       
       if candidates.length > 0

         # if we have > matches on the name, give user a choice
         if candidates.length > 1
           index = 1
           choices = []
         
           printf "%-3s [%-12s] %-10s %-20s %-60s\n", "Index", "Repository", "Category", "Name", "Description"
           candidates.each do |category, template|
             printf "%-5s [%-12s] %-10s %-20s %-60s\n", index.to_s, template["repo"], template["category"], template["name"], template["short_description"]                
             choices << index.to_s    
             index += 1
           end
    
           say_info "Multiple matches for #{options[:name]}. "
           selection = ask("Choose quickstart: [" + choices.join(",") + "]").to_i - 1
           if not candidates.to_a[selection].nil? then
             template = candidates.to_a[selection]
             return template[1]
           else
             say_error "Choice was not valid."
           end

         else
           # We only found one match for that quickstart name
           candidates.each do |category, template|
             return template
           end
         end             
       end
       nil
    end
    

    def get_version(project_version, component, composite=true) 
      if composite
        @versions[project_version[0..1]][component] + project_version
      else
        @versions[project_version[0..1]][component]
      end
    end
  
    def say_task(name)
       say "\033[1m\033[32m" + "task".rjust(10) + "\033[0m" + "  #{name} .." 
    end
    
    def say_debug(name)
       say "\033[1m\033[36m" + "debug".rjust(11) + "\033[0m" + "   #{name}" 
    end
    
    def say_warn(name)
       say "\033[1m\033[36m" + "warn".rjust(10) + "\033[0m" + "  #{name}" 
    end
    
    def say_error(name)
       say "\033[1m\033[31m" + "error".rjust(10) + "\033[0m" + "  #{name}" 
    end
    
    
    
  end
end
