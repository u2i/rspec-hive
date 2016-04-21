module RSpec
  module Hive
    class QueryBuilder
      class Rows
        attr_reader :schema, :partition

        def initialize(schema, rows, partition = nil)
          @schema = schema
          @rows = rows
          @partition = partition
        end

        def values
          validate_rows!

          rows.map(&:to_a)
        end

        def ==(other)
          schema == other.schema &&
            rows == other.rows &&
            partition == other.partition
        end

        protected

        attr_reader :rows

        private

        def schema_column_count
          schema.instance_variable_get(:@columns).size
        end

        def validate_rows!
          rows.each do |row|
            if row.size != schema_column_count
              raise ArgumentError,
                    "#{row} should have #{schema_column_count} values"
            end
          end
        end
      end

      module ConnectionDelegatorExtension
        def load_rows(rows)
          load_into_table(rows.schema, rows.values, rows.partition)
        end
      end
    end
  end
end
