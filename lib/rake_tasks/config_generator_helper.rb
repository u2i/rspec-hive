require 'hive_tests'
require_relative 'rake_includer'

class ConfigGeneratorHelper
  def self.generate_config
    config = RakeConfig.load_config(HiveTests::Configuration.new)
    create_host_shared_directory(config)
    save_to_file(config)
  end

  def self.save_to_file(config)
    File.open(config['config_file']['file_path'], 'w+') do |f|
      f.write config['hive'].to_yaml
      puts "Default config written to #{f.path}".green
    end
  end

  def self.create_host_shared_directory(config)
    system 'mkdir', '-p', config['hive']['host_shared_directory_path']
  end
end
