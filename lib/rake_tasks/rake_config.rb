class RakeConfig
  def self.default_docker_image_name
    'nielsensocial/hive'
  end

  def self.load_config(config)
    {
      'hive' => load_hive_config(config),
      'config_file' => load_config_file_config,
      'docker' => load_docker_config
    }
  end

  def self.load_hive_config(config)
    {
      'host' => ENV['HOST'] || config.host,
      'port' => ENV['PORT'] || config.port,
      'host_shared_directory_path' =>
        ENV['HOST_SHARED_DIR'] || config.host_shared_directory_path,
      'docker_shared_directory_path' =>
        ENV['DOCKER_SHARED_DIR'] || config.docker_shared_directory_path,
      'hive_version' => ENV['HIVE_VERSION'] || config.hive_version
    }
  end

  def self.load_config_file_config
    {
      'file_path' => ENV['CONFIG_FILE_PATH'] || default_config_file_path
    }
  end

  def self.load_docker_config
    {
      'image_name' => ENV['DOCKER_IMAGE_NAME'] || default_docker_image_name
    }
  end

  def self.default_config_file_path
    if defined?(Rails)
      File.join('.', 'config', 'hive_tests_config.yml')
    else
      File.join('.', 'hive_tests_config.yml')
    end
  end
end
