class Configuration
  attr_accessor :host, :port, :host_shared_directory_path, :docked_shared_directory_path

  def initialize(path_to_config_file = nil)
    if path_to_config_file.nil?
      @host = '127.0.0.1'
      @port = '10000'
      @host_shared_directory_path = '/Users/Shared/tmp/spec-files'
      @docked_shared_directory_path = '/tmp/spec-tmp-files'
    else
      @config = YAML.load_file(path_to_config_file)['hive']
      @host = @config['host']
      @port = @config['port']
      @host_shared_directory_path = @config['host_shared_directory_path']
      @docked_shared_directory_path = @config['docked_shared_directory_path']
    end
  end
end