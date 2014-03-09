require 'rubygems'
require 'thor'
require 'fusegen/repo'
require 'fusegen/new'
require 'fusegen/add'
require 'fusegen/quickstart'
require 'fusegen/util'
require 'fusegen/wizard'

class Generator < Thor
  include Thor::Actions
  include Thor::Shell
  include Generator::New
  include Generator::Repo
  include Generator::Add
  include Generator::Quickstart
  include Generator::Util
  include Generator::Wizard
  
  
  attr_accessor :versions
  attr_accessor :wizard
  
  def self.source_root
    File.dirname(__FILE__)
  end
    
private

  def source_paths
     [Dir.pwd] + super
  end

end
