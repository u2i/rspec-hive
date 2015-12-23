require 'yaml'
require 'colorize'
require 'tmpdir'

namespace :hive_tests do
  namespace :config do
    desc 'Generates example config file. Accepts directory to file.'
    task :generate_default, [:config_directory, :config_file_name] do |_, args|
      require 'rbconfig'

      host_os = RbConfig::CONFIG['host_os']
      host = host_os =~ /darwin|mac os/ ? '192.168.99.100' : '127.0.0.1'

      default_values = {
        'hive' =>
          {
            'host' => host,
            'port' => 10000,
            'host_shared_directory_path' =>
              File.join(Dir.mktmpdir, 'spec-tmp-file'),
            'docker_shared_directory_path' => '/tmp/spec-tmp-file',
            'hive_version' => '10'
          }
      }
      file_path = File.join(
        args[:config_directory],
        args[:config_file_name] || 'hive_tests_config.yml'
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
    task :run, [:config_file, :docker_image_name] do |_, args|
      puts 'Command `docker` not found.'.red unless system('which docker')

      docker_image_name = args[:docker_image_name] || 'nielsensocial/hive'

      interpolated = ERB.new(File.read(args[:config_file])).result
      config = YAML.load(interpolated)['hive']

      cmd = "docker run -v #{config['host_shared_directory_path']}:"\
            "#{config['docker_shared_directory_path']}"\
            " -d -p #{config['port']}:10000 #{docker_image_name}"

      puts "Running `#{cmd}`...".green
      system(cmd)
    end

    desc 'Downloads docker image from dockerhub.'
    task :download_image, [:docker_image_name] do |_, args|
      puts 'Command `docker` not found.'.red unless system('which docker')

      docker_image_name = args[:docker_image_name] || 'nielsensocial/hive'

      cmd = "docker pull #{docker_image_name}"
      puts "Running `#{cmd}`...".green
      system(cmd)
    end
  end
end
