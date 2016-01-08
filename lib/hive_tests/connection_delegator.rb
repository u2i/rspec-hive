require 'delegate'
require 'tempfile'

module HiveTests
  class ConnectionDelegator < SimpleDelegator
    def initialize(connection, config)
      super(connection)
      @config = config
    end

    def load_into_table(table_name, values, partitions = nil)
      Tempfile.open(table_name, @config.host_shared_directory_path) do |file|
        write_values_to_file(file, values)
        partition_clause = partition_clause(partitions) if partitions
        load_file_to_hive_table(table_name, translate_to_docker_path(file), partition_clause)
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

    def partition_clause(partitions)
      "PARTITION(#{partitions.map { |k, v| "#{k}='#{v}'" }.join(',')})"
    end

    def load_file_to_hive_table(table_name, path, partition_clause = '')
      execute("load data local inpath '#{path}' into table #{table_name} #{partition_clause}")
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
