require 'rspec/matchers'

RSpec::Matchers.define :match_result_set do |expected|
  match do |actual|
    return false if expected.size != actual.size
    @diffable_actual = []
    expected.map.with_index do |expected_row, i|
      if expected_row.respond_to?(:each_pair)
        if @partial_match
          @diffable_actual << actual[i].select { |k, _v| expected_row.keys.include?(k) }
          selected_actual_values = actual[i].values_at(*expected_row.keys)
          values_match?(expected_row.values, selected_actual_values)
        else
          @diffable_actual << actual[i]
          values_match?(expected_row, actual[i])
        end
      elsif expected_row.respond_to?(:each)
        raise ArgumentError, "Can't use partially matcher with Arrays" if @partial_match
        @diffable_actual << actual[i].values
        values_match?(expected_row, actual[i].values)
      else
        raise ArgumentError, 'Unknown type'
      end
    end.all?
  end

  chain :partially do
    @partial_match = true
  end

  failure_message do |actual|
    "expected #{actual} to match result set #{expected}\n#{diff_message(expected)}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual} not to match result set #{expected}, but did\n#{diff_message(expected)}"
  end

  def diff_message(expected)
    "Diff: #{differ.diff_as_object(@diffable_actual, expected)}"
  end

  def differ
    RSpec::Support::Differ.new(
      object_preparer: ->(object) { surface_descriptions_in(object) },
      color: RSpec::Matchers.configuration.color?
    )
  end

  # Copied and adapted from RSpec::Matchers::Composable
  # rubocop:disable Style/CaseEquality
  def surface_descriptions_in(item)
    if RSpec::Matchers.is_a_describable_matcher?(item)
      RSpec::Matchers::Composable::DescribableItem.new(item)
    elsif Hash === item
      Hash[surface_descriptions_in(item.to_a.sort)]
    elsif Struct === item || unreadable_io?(item)
      RSpec::Support::ObjectFormatter.format(item)
    elsif should_enumerate?(item)
      item.map { |subitem| surface_descriptions_in(subitem) }
    else
      item
    end
  end
  # rubocop:enable Style/CaseEquality
end
