class HiveConfig

  attr_reader :host, :port

  def initialize(path_to_config_file)
    @config = YAML.load_file(path_to_config_file)['hive']
    @host = @config['host']
    @port = @config['port']
  end
end