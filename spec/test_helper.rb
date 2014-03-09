
FUSEGEN_ROOT = "#{File.expand_path(File.dirname(__FILE__))}/.." unless defined?( FUSEGEN_ROOT )

SPEC_ROOT = FUSEGEN_ROOT + "/spec" unless defined?( SPEC_ROOT )

module TempDirectorySupport
  def self.included(base)
    base.extend(self)
  end

  def new_tmp_directory(directory)
    before do
      @pwd = Dir.pwd
      @tmp_dir = File.join(File.dirname(__FILE__), directory)
      FileUtils.mkdir_p(@tmp_dir)
      Dir.chdir(@tmp_dir)
    end

    after do
      Dir.chdir(@pwd)
      FileUtils.rm_rf(@tmp_dir)
    end
  end
end