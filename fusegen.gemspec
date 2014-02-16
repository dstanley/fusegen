# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','fusegen','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'fusegen'
  s.version = Fusegen::VERSION
  s.author = 'Dave Stanley'
  s.email = 'dstanleyd@gmail.com'
  s.homepage = 'https://github.com/dstanley'
  s.platform = Gem::Platform::RUBY
  s.summary = 'JBoss Fuse Code Generator'
  s.description = 'Code generator that simplifies generating new JBoss Fuse projects'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','fusegen.rdoc']
  s.rdoc_options << '--title' << 'fusegen' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'fusegen'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.9.0')
  s.add_runtime_dependency('thor','0.18.1')
end
