require 'rubygems'
require 'thor'

class Generator < Thor

  module New
      
      def new_project(options)
        do_new_project options  
      end
      
      private
      
      def do_new_project(options)

        begin
            # Map package name to corresponding directory path
            base_path = options[:groupid].gsub('.', '/')
          
            # Find project meta data from the quickstarts repository index
            quickstart = find_quickstart(options)
            
            if not quickstart.nil? 
              # Handle case of relative path in a repo index file (needed for rspec tests)
              if options[:appendbaseuri]
                options[:gitbase] = options[:gitbase] + quickstart["baseuri"]  
              else # else default runtime behavior, we grab the base uri from repository index file
                options[:gitbase] = quickstart["baseuri"]  
              end
              options[:category] = quickstart["category"]
              
              if options[:debug]
                say_debug ":gitbase " + options[:gitbase]
                say_debug ":category " + options[:category]
              end
              
              if not options[:gitbase].end_with?('/')
                options[:gitbase] = options[:gitbase] + "/"
              end
             
              say_task "Creating " + options[:name] 
              
              # Download manifest
              copy_from_repo 'manifest.yml', 'manifest.yml', options

              project = load_file 'manifest.yml', options

              if project.size > 0
                process_manifest = true
                wizard_mode = false
                
                # Check if this template is a wizard 
                if not project["wizard_name"].nil?
                  wizard_mode = true
                 
                  options[:wizardname] = project["wizard_name"]
                  load_wizard options
                
                  # Give custom wizard chance to collect its own params
                  @wizard.before(options)
                
                  # Let the wizard decide if we copy files in template manifest
                  process_manifest = @wizard.generate?(options)
                end

                if process_manifest
                  # Copy files as defined by the manifest
                  project["copies"].each do |source, destination| 
                    destination.gsub! '@base_path',base_path
                    copy_from_repo source, destination, options
                  end
                
                  # Substitute params within template files as defined by the manifest
                  project["subs"].each do |subs|      
                    subs[1].each do |sub| 
                       file = options[:name] + '/' + subs[0].dup
                       file.gsub! '@base_path',base_path
                       subvalue = get_substitution_value(sub, options) 
                       if options[:debug]
                          say_debug file + " gsub: '" + sub.to_s + "' value: '" + subvalue.to_s  + "'"                    
                       end
                       regex = Regexp.new /#{sub}/
                       gsub_file file, regex, subvalue, { :verbose => false }          
                    end
                  end
                end
                
                if wizard_mode
                  # Give wizard opportunity to post process and cleanup
                  @wizard.after(options)
                end 
                 
                
                # Cleanup at the end
                remove_file options[:name] + '/manifest.yml', { :verbose => false } 
              else  
                # Could not load a manifest.yml. Likely the path to load it was incorrect
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

  end 
  
end
