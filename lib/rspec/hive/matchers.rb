require 'rspec/matchers'

RSpec::Matchers.define :match_result_set do |expected|
  match do |actual|
    return false if expected.size != actual.size

    expected.each.with_index.all? do |expected_row, i|
      if expected_row.respond_to?(:each_pair)
        if @partial_match
          selected_actual_values = actual[i].values_at(*expected_row.keys)
          values_match?(expected_row.values, selected_actual_values)
        else
          values_match?(expected_row, actual[i])
        end
      elsif expected_row.respond_to?(:each)
        raise ArgumentError, "Can't use partially matcher with Arrays" if @partial_match
        values_match?(expected_row, actual[i].values)
      else
        raise ArgumentError, 'Unknown type'
      end
    end
  end

  chain :partially do
    @partial_match = true
  end

  diffable
end
