# frozen_string_literal: true

require 'rspec/matchers'

RSpec::Matchers.define :match_result_set do |expected|
  match do |actual|
    @diffable_actual = []

    @actual = actual.clone

    expected.map.with_index do |expected_row, i|
      if expected_row.respond_to?(:each_pair)
        if @partial_match
          result_set_match?(
            actual[i], expected_row,
            expected_transformer: ->(e) { e.values },
            actual_transformer: ->(candidate) { candidate.values_at(*expected_row.keys) },
            diffable_transformer: ->(candidate) { candidate.select { |k, _v| expected_row.keys.include?(k) } }
          )
        else
          result_set_match?(actual[i], expected_row)
        end
      elsif expected_row.respond_to?(:each)
        raise ArgumentError, "Can't use partially matcher with Arrays" if @partial_match
        result_set_match?(
          actual[i], expected_row,
          actual_transformer: ->(candidate) { candidate.values }
        )
      else
        raise ArgumentError, 'Unknown type'
      end
    end.all? && expected.size == actual.size
  end

  chain :partially do
    @partial_match = true
  end

  chain :unordered do
    @unordered = true
  end

  def result_set_match?(
    actual, expected_row,
    expected_transformer: ->(expected) { expected },
    actual_transformer: ->(candidate) { candidate },
    diffable_transformer: actual_transformer
  )
    if @unordered
      unordered_result_set_match?(expected_row, expected_transformer, actual_transformer, diffable_transformer)
    else
      ordered_result_set_match?(actual, expected_row, expected_transformer, actual_transformer, diffable_transformer)
    end
  end

  def unordered_result_set_match?(expected_row, expected_transformer, actual_transformer, diffable_transformer)
    found_index = @actual.find_index do |candidate|
      values_match?(expected_transformer.call(expected_row), actual_transformer.call(candidate))
    end
    return false unless found_index
    found = @actual[found_index]
    @actual.delete_at(found_index)
    @diffable_actual << diffable_transformer.call(found)
    true
  end

  def ordered_result_set_match?(actual, expected_row, expected_transformer, actual_transformer, diffable_transformer)
    @diffable_actual << diffable_transformer.call(actual)
    values_match?(expected_transformer.call(expected_row), actual_transformer.call(actual))
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
