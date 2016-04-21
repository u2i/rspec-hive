require_relative 'query_builder/row_transformer'
require_relative 'query_builder/null_strategy'
require_relative 'query_builder/value_by_type_strategy'

module RSpec
  module Hive
    class QueryBuilder
      def initialize(schema, connection)
        @schema = schema
        @connection = connection
        @partition = {}
        @rows = []
        @stubbing = false
      end

      def partition(partition)
        dup.tap do |builder|
          builder.partition.merge(partition)
        end
      end

      # []
      # [[], []]
      def insert(*rows)
        dup.tap do |builder|
          builder.rows.concat(rows)
        end
      end

      def execute
        if partition.empty?
          connection.load_into_table(schema, transformed_rows)
        else
          connection.load_into_table(schema, transformed_rows, partition)
        end
      end

      def with_stubbing
        dup.tap do |builder|
          builder.stubbing = true
        end
      end

      protected

      attr_accessor :partition, :connection, :rows, :stubbing

      private

      attr_reader :schema

      def stubbing?
        stubbing
      end

      def transformed_rows
        transformer = RowTransformer.new(schema, missing_column_strategy)
        rows.map do |row|
          transformer.transform(row)
        end
      end

      def missing_column_strategy
        if stubbing?
          ValueByTypeStrategy.new
        else
          NullStrategy.new
        end
      end
    end
  end
end
