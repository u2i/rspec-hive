require_relative 'type_faker'

module RSpec
  module Hive
    class QueryBuilder
      class RowTransformer
        def initialize(schema, missing_column_strategy)
          @schema = schema
          @strategy = missing_column_strategy
        end

        def transform(row)
          if row.respond_to?(:each_pair)
            mock_hive_row(row)
          elsif row.respond_to?(:each)
            size = schema.instance_variable_get(:@columns).size
            missing = size - row.size
            if missing > 0
              schema.columns.map.with_index do |column, index|
                if index > row.size
                  strategy.missing(column)
                else
                  row[index]
                end
              end

            else
              row
            end
          else
            raise ArgumentError, 'Array or Hash required!'
          end
        end

        private

        attr_reader :schema, :strategy

        HIVE_NIL = '\N'

        def mock_hive_row(partial_row)
          schema.columns.map do |column|
            value = partial_row.fetch(column.name) { strategy.missing(column) }
            nil_to_null(value)
          end
        end

        def nil_to_null(value)
          value.nil? ? HIVE_NIL : value
        end
      end
    end
  end
end
