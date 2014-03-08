require 'rubygems'
require 'thor'



class Generator < Thor

  module Quickstart
    
    def qs_list(global_options,options,args)
      do_qs_list
    end

    def qs_info(options,args)
      do_qs_info args[0], options
    end

    
    private

    def do_qs_info(qs, options={})    
      begin  
        options[:name] = qs
        template = find_quickstart options   
      
        options[:gitbase] = template["baseuri"] 
        base_uri = template["category"] + "/" + template["name"] + "/"
       
        if not options[:gitbase].end_with?('/')
          options[:gitbase] = options[:gitbase] + "/"
        end
        options[:category] = "none"
        options[:verbose] = false
        copy_from_repo base_uri + "README.md", ".readme", options
        file = File.open(".readme", "rb")
        contents = file.read
        file.close
        remove_file ".readme", { :verbose => false } 
        printf contents
        true
      rescue Exception => e  
        puts e.message  
        puts e.backtrace
        false
      end
    end
    
    def do_qs_list(options={})
      begin 
        quickstarts = get_quickstarts(options)
        
        if quickstarts.size > 0 
          printf "%-10s %-12s %-10s %-20s %-60s\n", "Version", "Repository", "Category", "Name", "Description"
        end

        quickstarts.each do |category, meta|
          meta.each do |template|
            printf "[%-8s] %-12s %-10s %-20s %-60s\n", template["version"], template["repo"], category, template["name"], template["short_description"]
          end
        end
      rescue Exception => e  
         puts e.message  
         puts e.backtrace
      end 
    end
  
    
  end
end
