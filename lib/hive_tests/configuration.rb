require 'tmpdir'

module HiveTests
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
        config = YAML.load(interpolated)['hive']
        load_variables_from_config(config)
      end
      @logger = Logger.new(STDOUT)
    end

    private

    def load_default_variables
      @host = '192.168.99.100'
      @port = 10000
      @host_shared_directory_path = '/Users/Shared/tmp/spec-tmp-files'
      @docker_shared_directory_path = '/tmp/spec-tmp-files'
      @hive_version = default_version
      @connection_timeout = default_timeout
      @hive_options = default_hive_options
    end

    def load_variables_from_config(config)
      @host = config['host']
      @port = config['port']
      @host_shared_directory_path = config['host_shared_directory_path']
      @docker_shared_directory_path = config['docker_shared_directory_path']
      @hive_version = (config['hive_version'] || default_version).to_i
      @connection_timeout = (config['timeout'] || default_timeout).to_i
      @hive_options = merge_config_options(default_hive_options, config)
    end

    def merge_config_options(hash, config)
      hash.merge(config['hive_options'].to_h)
    end

    def default_timeout
      1800
    end

    def default_version
      10
    end

    def default_hive_options
      {'hive.exec.dynamic.partition' => 'true',
       'hive.exec.dynamic.partition.mode' => 'nonstrict',
       'hive.exec.max.dynamic.partitions.pernodexi' => '100000',
       'hive.exec.max.dynamic.partitions' => '100000',
       'mapred.child.java.opts' => '-Xmx2048m'}
    end
  end
end
