require 'delegate'
require 'tempfile'

module HiveTests
  class ConnectionDelegator < SimpleDelegator
    def initialize(connection, config)
      super(connection)
      @config = config
    end

    def load_into_table(table_name, values)
      Tempfile.open(table_name, @config.host_shared_directory_path) do |file|
        write_values_to_file(file, values)
        load_file_to_hive_table(table_name, translate_to_docker_path(file))
      end
    end

    def show_tables
      fetch('SHOW TABLES')
    end

    def create_database(name)
      execute("CREATE DATABASE IF NOT EXISTS `#{name}`")
    end

    def use_database(name)
      execute("USE `#{name}`")
    end

    def drop_database(name)
      execute("DROP DATABASE `#{name}`")
    end

    def show_databases
      fetch('SHOW DATABASES')
    end

    def switch_database(db_name)
      create_database(db_name)
      use_database(db_name)
    end

    private

    def load_file_to_hive_table(table_name, path)
      execute("load data local inpath '#{path}' into table #{table_name}")
    end

    def translate_to_docker_path(file)
      File.join(@config.docker_shared_directory_path, File.basename(file.path))
    end

    def write_values_to_file(file, values)
      values.each { |value| file.puts(value.join(';')) }
      file.flush
    end
  end
end
