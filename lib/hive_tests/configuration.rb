module HiveTests
  class Configuration
    attr_accessor :host, :port, :host_shared_directory_path, :docker_shared_directory_path

    def initialize(path_to_config_file = nil)
      if path_to_config_file.nil?
        @host = '192.168.99.100'
        @port = '10000'
        @host_shared_directory_path = '/Users/Shared/tmp/spec-tmp-files'
        @docker_shared_directory_path = '/tmp/spec-tmp-files'
      else
        @config = YAML.load_file(path_to_config_file)['hive']
        @host = @config['host']
        @port = @config['port']
        @host_shared_directory_path = @config['host_shared_directory_path']
        @docker_shared_directory_path = @config['docker_shared_directory_path']
      end
    end
  end
end
