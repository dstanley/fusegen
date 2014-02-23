require 'rubygems'
require 'thor'



class Generator < Thor

  module Repo


    def repo_list(global_options,options,args)
      do_repo_list
    end

    def repo_add(global_options,options,args)
      check_config_dir
      do_repo_add args[0], options
    end

    def repo_rm(global_options,options,args)
      do_repo_rm args[0], options
    end

    def repo_find_template(name)
      do_repo_find_template name
    end
    
    private
    
    def check_config_dir
      if not File.directory?("~/.fusegen")
        empty_directory "~/.fusegen", { :verbose => false }
      end
    end

    def do_repo_add(path, options={})
      begin

        options[:verbose] = false
        if path =~ /http/
          if not path.end_with?('/')
            path = path + "/"
          end
          # convert to a raw github uri if we need to
          path = path.gsub(/\/github.com/, "\/raw.github.com")
          options[:gitbase] = path
          copy_from_github 'index.yml', '.index', options
        else
          copy_file path + "/index.yml", ".index", options
        end
  
        config = YAML.load_file(".index")
  
        pp config

        meta = config["meta"] 
        if meta && meta["baseuri"] && meta["author"] 
          meta["expires"] = Time.now + (3*24*60*60) # cache for 3 days
          File.open(".index", 'w') { |file| YAML::dump(config, file)}
          copy_file ".index", "~/.fusegen/#{meta["author"].gsub(/\s+/, "").downcase}/index", options
          repos = load_file "~/.fusegen/repos"
          repos[meta["author"]] = { "meta" => meta["author"].gsub(/\s+/, "").downcase }
          File.open(File.expand_path('~') + "/.fusegen/repos", 'w') { |file| YAML::dump(repos, file) }
          puts "Added repository '#{meta["author"]}'"
        else
          puts "Unable to add '#{path}'. Repository is invalid or missing an index."
        end

        remove_file ".index", options
  
      rescue Exception => e  
        puts e.message  
        puts e.backtrace
      end
    end
  
  
    def do_repo_rm(key, options={})
       begin 
          options[:verbose] = false
          repos = load_file "~/.fusegen/repos"
          repos.tap { |hash| hash.delete(key) }
          File.open(File.expand_path('~') + "/.fusegen/repos", 'w') { |file| YAML::dump(repos, file) }
          remove_dir File.expand_path('~') + "/.fusegen/#{key}", options
        
        rescue Exception => e  
          if options[:debug]
            puts e.message  
            puts e.backtrace
          end        
        end
    end
  
 
    def do_repo_list(options={})
      begin 
        repos = load_file "~/.fusegen/repos"
      
        if repos.size > 0 
          printf "%-20s\n", "Repository"
        end
      
        repos.each do |key, value|
          printf "[%-20s] \n", key
        end
  
      rescue Exception => e  
        puts e.message  
        puts e.backtrace
      end 
    end
    
    
    def do_repo_find_template(name)
      
    end
    
  end
end
