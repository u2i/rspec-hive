# frozen_string_literal: true

require_relative 'query_builder/row_transformer'
require_relative 'query_builder/null_strategy'
require_relative 'query_builder/value_by_type_strategy'

module RSpec
  module Hive
    class QueryBuilder
      def initialize(schema, connection)
        @schema = schema
        @connection = connection
        @partition_hash = {}
        @rows = []
        @stubbing = false
      end

      def partition(hash)
        spawn.partition!(hash)
      end

      def partition!(partition)
        partition_hash.merge!(partition)
        self
      end

      def insert(*new_rows)
        spawn.insert!(new_rows)
      end

      def insert!(new_rows)
        rows.concat(new_rows)
        self
      end

      def execute
        if partition_hash.empty?
          connection.load_into_table(schema, transformed_rows)
        else
          connection.load_into_table(schema, transformed_rows, partition_hash)
        end
      end

      def with_stubbing
        spawn.with_stubbing!
      end

      def with_stubbing!
        self.stubbing = true
        self
      end

      protected

      attr_accessor :partition_hash, :connection, :rows, :stubbing

      private

      attr_reader :schema

      def spawn
        clone
      end

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
