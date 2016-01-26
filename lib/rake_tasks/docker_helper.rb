require 'colorize'
require 'hive_tests'
require_relative 'rake_includer'

class DockerHelper
  def self.run_docker
    return puts 'Command `docker` not found.'.red unless docker_installed?

    config_file_path = RakeConfig.default_config_file_path
    config = load_config_file(config_file_path)
    run_docker_using_config(config)
  end

  def self.download_image
    return puts 'Command `docker` not found.'.red unless docker_installed?

    docker_image_name = RakeConfig.default_docker_image_name

    cmd = "docker pull #{docker_image_name}"
    puts "Running `#{cmd}`...".green
    system(cmd)
  end

  def self.docker_installed?
    system('which docker')
  end

  def self.run_docker_using_config(config)
    docker_image_name = RakeConfig.default_docker_image_name
    cmd = "docker run -v #{config['host_shared_directory_path']}:"\
            "#{config['docker_shared_directory_path']}"\
            " -d -p #{config['port']}:10000 #{docker_image_name}"

    puts "Running `#{cmd}`...".green
    system(cmd)
  end

  def self.load_config_file(file_path)
    unless File.exist? file_path
      return puts "There's no config file #{file_path} please "\
            'generate default or provide custom config.'.red
    end

    interpolated = ERB.new(File.read(file_path)).result
    YAML.load(interpolated)['hive']
  end
end
