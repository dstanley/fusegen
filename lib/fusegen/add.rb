require 'rubygems'
require 'thor'



class Generator < Thor

  module Add

    def add_index
      add_template_index
    end
    
    def add_feature
      puts "[TODO] Add a feature file"
    end
    
    def add_feature
      puts "[TODO] Add a readme file"
    end
    
   
    private
    
    # Creates an index for a template repository
    def add_template_index
      index = {}
      quickstarts = {}

      puts ""
      username = ask "What is your github username?"
      baseuri = "https://raw.github.com/#{username}/fusegen-templates/master"

      meta = {
        "version" => "0.0.1",
        "author" => username, 
        "baseuri" => baseuri
      }

      Dir.glob("**/*.yml").each do |file|
        path = file.split('/')

        if path.length > 2
          begin
             config = YAML.load_file(file)
          rescue Exception => e     
             puts "Error reading " + file   
          end

          # First element is the category, group all categories together
          if quickstarts[path[0]].nil?  
            quickstarts[path[0]] = []; 
          end
          data = { "name" => path[1], "manifest" => path[2], "short_description" => config["short_description"], 
                   "version" => config["version"] }
          quickstarts[path[0]] << data
        end
      end

      index["quickstarts"] = quickstarts
      index["meta"] = meta
      File.open("index.yml", 'w') { |file| YAML::dump(index, file)}

      puts "Created index.yml. Please verify the baseuri is correct."
    end
    
    
  end
end
