require 'rspec/matchers'
require 'pp'

RSpec::Matchers.define :match_result_set do |expected|
  match do |actual|
    matches = eq_match(expected, actual)
    array_match(expected, actual)
    matches
  end

  def map_hash_to_array(actual)
    actual.map! { |r| r.values }
  end

  def sort_hash_keys!(hash)
    hash.map! { |r| r.keys.sort.reduce({}) { |h, key| h[key] = r[key]; h } }
  end

  def remove_extra_keys!(expected, actual)
    partial_keys = expected[0].keys
    actual.map! { |r| r.select { |k, _| partial_keys.include?(k) } }
  end

  def eq_match(expected, actual)
    return actual.empty? if expected.empty?

    if expected[0].is_a?(Array)
      raise ArgumentError, 'Can\'t use partially matcher with Arrays' if @partial_match
      map_hash_to_array(actual)
    end

    remove_extra_keys!(expected, actual) if @partial_match

    sort_hash_keys!(actual) if actual[0].is_a?(Hash)
    sort_hash_keys!(expected) if expected[0].is_a?(Hash)

    if @unordered
      actual.sort_by!(&:to_s)
      expected.sort_by!(&:to_s)
    end

    @matcher = RSpec::Matchers::BuiltIn::Match.new(expected)
    @matcher.matches?(actual)
  end

  def array_match(expected, actual)
    @array_matcher = RSpec::Matchers::BuiltIn::ContainExactly.new(expected)
    @array_matches = @array_matcher.matches?(actual)
  end

  chain :partially do
    @partial_match = true
  end

  chain :unordered do
    @unordered = true
  end

  failure_message do |_|
    message = @matcher.failure_message
    unless @array_matches
      missing = @array_matcher.send(:missing_items).pretty_inspect
      extra = @array_matcher.send(:extra_items).pretty_inspect

      message += "\n"
      message += 'missing items: ' + missing
      message += 'extra items: ' + extra
      message += 'diff: ' + RSpec::Support::Differ.new.diff_as_object(missing, extra).to_s

    end
    message
  end

  failure_message_when_negated do |_|
    message = @matcher.failure_message_when_negated
    unless @array_matches
      message += "\n"
      message += 'missing items: ' + @array_matcher.send(:missing_items).pretty_inspect
      message += 'extra items: ' + @array_matcher.send(:extra_items).pretty_inspect
    end
  end
end
