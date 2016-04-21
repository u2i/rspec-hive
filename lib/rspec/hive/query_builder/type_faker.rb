require 'faker'

module RSpec
  module Hive
    class QueryBuilder
      class TypeFaker
        class << self
          def mock(type)
            case type
            when :int
              Faker::Number.number(9)
            when :smallint
              Faker::Number.number(4)
            when :tinyint
              Faker::Number.number(1)
            when :bigint
              Faker::Number.number(12)
            when :float
              Faker::Number.decimal(4, 4)
            when :double
              Faker::Number.decimal(8, 8)
            when :boolean
              Faker::Boolean.boolean
            when :string
              Faker::Lorem.word
            else
              raise ArgumentError, "Unsupported type: #{type}"
            end
          end
        end
      end
    end
  end
end
