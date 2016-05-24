require 'rspec/matchers'

RSpec::Matchers.define :match_result_set do |ex|
  match do |act|
    actual = act
    expected = ex

    if Array === expected[0]
      raise ArgumentError, "Can't use partially matcher with Arrays" if @partial_match
      actual = actual.map { |r| r.values }
    end

    if @partial_match
      partial_keys = expected[0].keys
      actual = actual.map { |r| r.select { |k, _| partial_keys.include?(k) } }
    end

    if @unordered
      actual = actual.sort_by(&:to_s)
      expected = expected.sort_by(&:to_s)
    end

    @array_matcher = RSpec::Matchers::BuiltIn::ContainExactly.new(expected)
    @array_matches = @array_matcher.matches?(actual)

    @matcher = RSpec::Matchers::BuiltIn::Match.new(expected)
    @matcher.matches?(actual)
  end

  chain :partially do
    @partial_match = true
  end

  chain :unordered do
    @unordered = true
  end

  failure_message do |_|
    message = @matcher.failure_message
    message += "\n" + @array_matcher.failure_message unless @array_matches
    message
  end

  failure_message_when_negated do |_|
    message = @matcher.failure_message_when_negated
    message += "\n" + @array_matcher.failure_message_when_negated unless @array_matches
    message
  end
end
