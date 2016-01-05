require 'yaml'
require 'colorize'
require 'tmpdir'

namespace :hive_tests do
  namespace :config do
    desc 'Generates example config file. Accepts directory to file.'
    task :generate_default do
      require 'rbconfig'

      host_os = RbConfig::CONFIG['host_os']
      host = host_os =~ /darwin|mac os/ ? '192.168.99.100' : '127.0.0.1'

      default_values = {
        'hive' =>
          {
            'host' => ENV['HOST'] || host,
            'port' => ENV['PORT'] || 10000,
            'host_shared_directory_path' =>
              ENV['HOST_SHARED_DIR'] || host_os =~ /darwin|mac os/ ?
                File.join(Dir.mktmpdir(nil, '/Users/Shared'), 'spec-tmp-files') : File.join(Dir.mktmpdir, 'spec-tmp-files'),
            'docker_shared_directory_path' =>
              ENV['DOCKER_SHARED_DIR'] || '/tmp/spec-tmp-files',
            'hive_version' =>
              ENV['HIVE_VERSION'] || 10
          }
      }
      system 'mkdir', '-p', default_values['hive']['host_shared_directory_path']
      file_path = File.join(
        ENV['CONFIG_FILE_DIR'] || '.',
        ENV['CONFIG_FILE_NAME'] || 'hive_tests_config.yml'
      )
      File.open(file_path, 'w+') do |f|
        f.write default_values.to_yaml
        puts "Default config written to #{f.path}".green
      end
    end
  end

  namespace :docker do
    desc 'Runs docker using hive config file.'\
          ' It assumes your docker-machine is running.'
    task :run do
      puts 'Command `docker` not found.'.red unless system('which docker')

      config_filepath = ENV['CONFIG_FILE'] || 'hive_tests_config.yml'
      docker_image_name = ENV['DOCKER_IMAGE_NAME'] || 'nielsensocial/hive'
      unless File.exist? config_filepath
        puts "There's no config file #{config_filepath} please generate default or provide custom config.".red
        raise Errno::ENOENT.new config_filepath unless File.exist? config_filepath
      end

      interpolated = ERB.new(File.read(config_filepath)).result
      config = YAML.load(interpolated)['hive']

      cmd = "docker run -v #{config['host_shared_directory_path']}:"\
            "#{config['docker_shared_directory_path']}"\
            " -d -p #{config['port']}:10000 #{docker_image_name}"

      puts "Running `#{cmd}`...".green
      system(cmd)
    end

    desc 'Downloads docker image from dockerhub.'
    task :download_image do
      puts 'Command `docker` not found.'.red unless system('which docker')

      docker_image_name = ENV['DOCKER_IMAGE_NAME'] || 'nielsensocial/hive'

      cmd = "docker pull #{docker_image_name}"
      puts "Running `#{cmd}`...".green
      system(cmd)
    end
  end
end
