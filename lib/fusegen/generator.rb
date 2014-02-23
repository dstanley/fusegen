require 'rubygems'
require 'thor'
require 'fusegen/repo'
require 'fusegen/new'
require 'fusegen/add'
require 'fusegen/quickstart'
require 'fusegen/util'

class Generator < Thor
  include Thor::Actions
  include Thor::Shell
  include Generator::New
  include Generator::Repo
  include Generator::Add
  include Generator::Quickstart
  include Generator::Util
  
  attr_accessor :versions

  def self.source_root
    File.dirname(__FILE__)
  end
    
private

  def source_paths
     [Dir.pwd] + super
  end

end
