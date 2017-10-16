# frozen_string_literal: true

require 'yaml'
require 'colorize'
require 'tmpdir'
require 'rspec/hive'
require 'erb'

namespace :spec do
  namespace :hive do
    namespace :config do
      desc 'Generates example config file. Accepts directory to file.'
      task :generate_default do
        require 'rbconfig'

        default_config = RSpec::Hive::Configuration.new

        default_values = {
          'hive' =>
            {
              'host' => ENV['HOST'] || default_config.host,
              'port' => ENV['PORT'] || default_config.port,
              'host_shared_directory_path' =>
                ENV['HOST_SHARED_DIR'] || default_config.host_shared_directory_path,
              'docker_shared_directory_path' =>
                ENV['DOCKER_SHARED_DIR'] || default_config.docker_shared_directory_path,
              'hive_version' =>
                ENV['HIVE_VERSION'] || default_config.hive_version,
              'hive_options' => {
                'hive.exec.dynamic.partition' => 'true',
                'hive.exec.dynamic.partition.mode' => 'nonstrict',
                'hive.exec.max.dynamic.partitions.pernodexi' => '100000',
                'hive.exec.max.dynamic.partitions' => '100000',
                'mapred.child.java.opts' => '-Xmx2048m'
              }
            }
        }
        system 'mkdir', '-p', default_values['hive']['host_shared_directory_path']
        system 'mkdir', '-p', 'config'

        file_path = ENV['CONFIG_FILE'] || File.join('config', 'rspec-hive.yml')

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
        raise 'Command `docker` not found.'.red unless system('which docker')

        config_filepath = ENV['CONFIG_FILE'] || File.join('config', 'rspec-hive.yml')
        unless File.exist? config_filepath
          raise "There's no config file #{config_filepath} please"\
               'generate default or provide custom config.'.red
        end

        interpolated = ERB.new(File.read(config_filepath)).result
        config = YAML.safe_load(interpolated)['hive']

        docker_image_name = ENV['DOCKER_IMAGE_NAME'] || 'nielsensocial/hive'
        cmd = "docker run -v #{config['host_shared_directory_path']}:"\
              "#{config['docker_shared_directory_path']}"\
              " -d -p #{config['port']}:10000 #{docker_image_name}"

        puts "Running `#{cmd}`...".green
        system(cmd)
      end

      desc 'Downloads docker image from dockerhub.'
      task :download_image do
        raise 'Command `docker` not found.'.red unless system('which docker')

        docker_image_name = ENV['DOCKER_IMAGE_NAME'] || 'nielsensocial/hive'

        cmd = "docker pull #{docker_image_name}"
        puts "Running `#{cmd}`...".green
        system(cmd)
      end

      def container_id
        return ENV['CONTAINER_ID'] if ENV['CONTAINER_ID']
        docker_conatiners = `docker ps`.lines
        if docker_conatiners.size != 2
          raise 'There is more than 1 instance of docker container running (or no running docker containers). '\
                'Check `docker ps` and stop containers that are not in use right now or specify CONTAINER_ID '\
                'and run this command again.'.red
        else
          docker_conatiners[1].split[0]
        end
      end

      desc 'Load Hive UDFS (user defined functions) onto docker.'
      task :load_udfs, [:udfs_path] do |_t, args|
        udfs_path = args[:udfs_path]
        config_filepath = ENV['CONFIG_FILE'] || File.join('config', 'rspec-hive.yml')
        interpolated = ERB.new(File.read(config_filepath)).result
        config = YAML.safe_load(interpolated)['hive']

        host_hive_udfs_path = File.join(config['host_shared_directory_path'], 'hive-udfs.jar')
        raise 'Please provide UDFS_PATH'.red unless udfs_path
        if udfs_path.start_with?('s3://')
          puts 'Downloading from s3...'.yellow
          cmd = "aws s3 ls #{udfs_path}"

          raise 'awscli is not configured.'.red unless system(cmd)
          cmd = "aws s3 cp #{udfs_path} #{host_hive_udfs_path}"
        else
          puts 'Copying from local directory...'.yellow
          cmd = "cp #{udfs_path} #{host_hive_udfs_path}"
        end
        system(cmd)
        puts 'Done'.green

        puts 'Copying to hadoop on docker...'.yellow
        cmd = "docker exec -it #{container_id} /bin/bash -c 'cp #{host_hive_udfs_path} $HADOOP_HOME'"
        system(cmd)
        puts 'Done'.green
      end
    end

    desc 'Runs beeline console on hive.'
    task :beeline do
      puts "Connecting to docker container: #{container_id} and running beeline. To exit: '!q'".green
      bash_cmd = '$HIVE_HOME/bin/beeline -u jdbc:hive2://localhost:10000 -d org.apache.hive.jdbc.HiveDriver'
      cmd = "docker exec -it #{container_id} /bin/bash -c #{bash_cmd}"
      system(cmd)
    end
  end
end
