$here = File.dirname __FILE__
require "#{$here}/cmock_header_parser"
require "#{$here}/cmock_generator"
require "#{$here}/cmock_file_writer"
require "#{$here}/cmock_config"
require "#{$here}/cmock_plugin_manager"
require "#{$here}/cmock_generator_utils"

class CMock
  
  def initialize(options=nil)
    @cfg = CMockConfig.new(options)
  end
  
  def setup_mocks(files)
    files.each do |src|
      generate_mock src
    end
  end

  private ###############################

  def generate_mock(src)
    name = File.basename(src, '.h')
    path = File.dirname(src)
    @cfg.set_path(path)
    
    cm_parser      = CMockHeaderParser.new(File.read(src))
    cm_writer      = CMockFileWriter.new(@cfg)
    cm_gen_utils   = CMockGeneratorUtils.new(@cfg)
    cm_gen_plugins = CMockPluginManager.new(@cfg, cm_gen_utils).get_generator_plugins
    cm_generator   = CMockGenerator.new(@cfg, name, cm_writer, cm_gen_utils, cm_gen_plugins)
    
    puts "Creating mock for #{name}..."
    
    parsed_stuff = cm_parser.parse
    cm_generator.create_mock(parsed_stuff)
  end
end

if ($0 == __FILE__)
  usage = "usage: ruby #{__FILE__} (-oOptionsFile) File(s)ToMock"
  
  if (!ARGV[0])
    puts usage
    exit 1
  end
  
  options = nil
  filelist = []
  ARGV.each do |arg|
    if (arg =~ /^-o(\w*)/)
      options = arg.gsub(/^-o/,'')
    else
      filelist << arg
    end
  end
  
  CMock.new(options).setup_mocks(filelist)
end