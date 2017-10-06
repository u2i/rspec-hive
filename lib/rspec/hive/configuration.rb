# frozen_string_literal: true

require 'tmpdir'

module RSpec
  module Hive
    class Configuration
      attr_accessor :host,
                    :port,
                    :host_shared_directory_path,
                    :docker_shared_directory_path,
                    :logger,
                    :hive_version,
                    :connection_timeout,
                    :hive_options

      def initialize(path_to_config_file = nil)
        if path_to_config_file.nil?
          load_default_variables
        else
          interpolated = ERB.new(File.read(path_to_config_file)).result
          config = YAML.safe_load(interpolated)['hive']
          load_variables_from_config(config)
        end
        @logger = Logger.new(STDOUT)
      end

      private

      def load_default_variables
        @host = '127.0.0.1'
        @port = 10000
        @host_shared_directory_path = platform_specific_host_shared_dir_path
        @docker_shared_directory_path = '/tmp/spec-tmp-files'
        @hive_version = default_version
        @connection_timeout = default_timeout
        @hive_options = {}
      end

      def load_variables_from_config(config)
        @host = config['host']
        @port = config['port']
        @host_shared_directory_path = config['host_shared_directory_path']
        @docker_shared_directory_path = config['docker_shared_directory_path']
        @hive_version = (config['hive_version'] || default_version).to_i
        @connection_timeout = (config['timeout'] || default_timeout).to_i
        @hive_options = config['hive_options'].to_h
      end

      def mac?
        host_os = RbConfig::CONFIG['host_os']
        host_os =~ /darwin|mac os/
      end

      def platform_specific_host_shared_dir_path
        if mac?
          File.join(Dir.mktmpdir(nil, '/Users/Shared'), 'spec-tmp-files')
        else
          File.join(Dir.mktmpdir, 'spec-tmp-files')
        end
      end

      def default_timeout
        120
      end

      def default_version
        10
      end
    end
  end
end
