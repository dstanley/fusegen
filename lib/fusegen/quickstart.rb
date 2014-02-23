require 'rubygems'
require 'thor'



class Generator < Thor

  module Quickstart
    
    def qs_list(global_options,options,args)
      do_qs_list
    end

    def qs_info(global_options,options,args)
      do_qs_info args[0], options
    end

    
    private

    def do_qs_info(template, options={})
      puts "[TODO] show readme for quickstart .."
    end
    
    def do_qs_list(options={})
      begin 
        quickstarts = get_quickstarts
        
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
