require 'rubygems'
require 'thor'
require 'yaml'

require 'fusegen/wizards/AmqWizard'

class Generator < Thor

  module Wizard
    
    def initialize
      super
    end
    
    # Dynamically load wizard class, assuming we have a good class name. 
    # Wizard class needs to be internal to the gem to ensure template is well behaved
    def load_wizard(options={})

        if options[:wizardname]
          @wizard = Object.const_get(options[:wizardname]).new
        end
    end
    
  end
end



  
