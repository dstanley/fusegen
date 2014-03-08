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
            base_path = options[:groupid].gsub('.', '/')
          
            quickstart = find_quickstart(options)
            
            if not quickstart.nil? 
              options[:gitbase] = quickstart["baseuri"]  
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

                project["copies"].each do |source, destination| 
                  destination.gsub! '@base_path',base_path
                  copy_from_repo source, destination, options
                end

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

                remove_file options[:name] + '/manifest.yml', { :verbose => false } 
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

  end 
  
end
