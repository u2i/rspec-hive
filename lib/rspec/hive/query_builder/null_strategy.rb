# frozen_string_literal: true

module RSpec
  module Hive
    class QueryBuilder
      class NullStrategy
        def missing(_column)
          nil
        end
      end
    end
  end
end
