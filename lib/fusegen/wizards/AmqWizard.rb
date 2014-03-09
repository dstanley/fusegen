require 'rubygems'
require 'thor'
require 'yaml'

class AmqWizard < Thor
  
  def initialize
    
  end
  
  # no_commands block to avoid thor interpreting as commands
  no_commands do
     def before(options={})
       puts "amq wizard before"
     end
     
     def generate?(options={})
       puts "amq wizard generate"
       true
     end
     
     def after(options={})
       puts "amq wizard after"
     end
     
   end
  
end