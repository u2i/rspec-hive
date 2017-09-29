require 'delegate'
require 'tempfile'

module RSpec
  module Hive
    class ConnectionDelegator < SimpleDelegator
      def initialize(connection, config)
        super(connection)
        @config = config
      end

      def create_table(table_schema)
        table_schema = table_schema.dup
        table_schema.instance_variable_set(:@location, nil)
        execute(table_schema.create_table_statement)
      end

      def load_partitions(table_schema, partitions)
        partitions = partition_clause(table_schema, partitions)
        query = "ALTER TABLE #{table_schema.name} ADD #{partitions}"
        execute(query)
      end

      def load_into_table(table_schema, values, partitions = nil)
        table_name = table_schema.name
        Tempfile.open(table_name, @config.host_shared_directory_path) do |file|
          write_values_to_file(
            file,
            values,
            table_schema.instance_variable_get(:@field_sep)
          )
          partition_query = partition_clause(table_schema, partitions) if partitions
          load_file_to_hive_table(
            table_name,
            docker_path(file),
            partition_query
          )
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

      def partition_clause(table_schema, partitions)
        if partitions.is_a?(Array)
          partitions.collect { |x| to_partition_clause(table_schema, x) }.join(' ')
        else
          to_partition_clause(table_schema, partitions)
        end
      end

      def to_partition_clause(table_schema, partition)
        "PARTITION(#{partition.map { |k, v| "#{k}=#{partition_value(table_schema, k, v)}" }.join(',')})"
      end

      def partition_value(table_schema, key, value)
        return value if table_schema.partitions.detect { |x| x.name == key && x.type == :int }
        "'#{value}'"
      end

      def load_file_to_hive_table(table_name, path, partition_clause = nil)
        request_txt =
          "load data local inpath '#{path}' into table #{table_name}"
        request_txt << " #{partition_clause}" unless partition_clause.nil?
        execute(request_txt)
      end

      def docker_path(file)
        File.join(
          @config.docker_shared_directory_path,
          File.basename(file.path)
        )
      end

      def write_values_to_file(file, values, delimiter = ';')
        values.each { |value| file.puts(value.join(delimiter)) }
        file.flush
      end
    end
  end
end
