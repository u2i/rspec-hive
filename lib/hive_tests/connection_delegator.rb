require 'delegate'
require 'tempfile'

module HiveTests
  class ConnectionDelegator < SimpleDelegator
    def initialize(connection, config)
      super(connection)
      @config = config
    end

    def create_table(table_schema)
      execute(table_schema.instance_variable_set(:@location, nil))
    end

    def load_partitions(table_name, partitions)
      partitions = partition_clause(partitions)
      query = "ALTER TABLE #{table_name} ADD #{partitions}"
      execute(query)
    end

    def load_into_table(table_name, values, partitions = nil)
      Tempfile.open(table_name, @config.host_shared_directory_path) do |file|
        write_values_to_file(file, values)
        partition_query = partition_clause(partitions) if partitions
        load_file_to_hive_table(table_name, docker_path(file), partition_query)
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
      if partitions.is_a?(Array)
        partitions.collect { |x| to_partition_clause(x) }.join(' ')
      else
        to_partition_clause(partitions)
      end
    end

    def to_partition_clause(partition)
      "PARTITION(#{partition.map { |k, v| "#{k}='#{v}'" }.join(',')})"
    end

    def load_file_to_hive_table(table_name, path, partition_clause = '')
      request_txt = "load data local inpath '#{path}' into table #{table_name}"
      request_txt << " #{partition_clause}" unless partition_clause.empty?
      execute(request_txt)
    end

    def docker_path(file)
      File.join(@config.docker_shared_directory_path, File.basename(file.path))
    end

    def write_values_to_file(file, values)
      values.each { |value| file.puts(value.join(';')) }
      file.flush
    end
  end
end
