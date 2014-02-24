require 'rubygems'
require 'thor'

class Generator < Thor

  module New
      
      def new_project(global_options,options,args)
        do_new_project options  
      end
      
      private
      
      def do_new_project(options)

        begin
            base_path = options[:groupid].gsub('.', '/')
          
            quickstart = find_quickstart(options)
            
            if not quickstart.nil? 
              options[:gitbase] = quickstart["baseuri"]  
              options[:category] = quickstart["category"]
              
              if options[:debug]
                say_info ":gitbase " + options[:gitbase]
                say_info ":gitbase " + options[:category]
              end
              
              if not options[:gitbase].end_with?('/')
                options[:gitbase] = options[:gitbase] + "/"
              end
             
              say_task "Creating " + options[:name] 
              
              # Download manifest
              copy_from_repo 'manifest.yml', 'manifest.yml', options

              project = load_file 'manifest.yml', options

              if project.size > 0

                project["copies"].each do |source, destination| 
                  destination.gsub! '@base_path',base_path
                  copy_from_repo source, destination, options
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
                say_error "We found the project but cannot read its manifest :-( '" + options[:name] + "'"
              end
            else
              say_error "Could not find '" + options[:name] + "'"
            end
          
         rescue Exception => e  
             if options[:debug]
               puts e.message  
               puts e.backtrace
             end
         end
      end
      
      
      def find_quickstart(options)
        # load all know quickstarts from cache
        quickstarts = get_quickstarts
        candidates = {}
        quickstarts.each do |category, meta|
            meta.each do |template|
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

  end 
  
end
