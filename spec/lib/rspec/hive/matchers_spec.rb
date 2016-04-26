require 'spec_helper'
require 'rspec/hive/query_builder_helper'

RSpec.describe 'match_result_set' do
  include RSpec::Hive::QueryBuilderHelper

  let(:john) { {first_name: 'John', last_name: 'Lennon', age: 40} }
  let(:paul) { {first_name: 'Paul', last_name: 'McCartney', age: 73} }

  let(:full_match) { expect(actual_rows).to match_result_set(expected_rows) }
  let(:partial_match) { expect(actual_rows).to match_result_set(expected_rows).partially }
  let(:full_match_fails) { expect(actual_rows).not_to match_result_set(expected_rows) }
  let(:partial_match_fails) { expect(actual_rows).not_to match_result_set(expected_rows).partially }

  context 'when the expected set has only one row' do
    context 'but the actual set has more rows' do
      let(:actual_rows) { [john, paul] }

      context 'when the row is given as an array' do
        let(:expected_rows) { [john.values] }

        specify { full_match_fails }
        specify { partial_match_fails }
      end

      context 'when the row is given as a hash' do
        let(:expected_rows) { [john] }

        specify { full_match_fails }
        specify { partial_match_fails }
      end
    end

    context 'and the actual set has one row' do
      let(:actual_rows) { [john] }

      context 'when the row is given as an array' do
        context 'when the number of columns differs' do
          let(:expected_rows) { [john.values << 'yoko'] }

          specify { full_match_fails }
        end

        context 'when the actual and expected have are different' do
          let(:expected_rows) { [paul.values] }

          specify { full_match_fails }
        end

        context 'when the actual and expected rows are equal' do
          let(:expected_rows) { [john.values] }

          specify { full_match }
        end

        context 'when the actual and expected rows are equal with rspec matchers' do
          let(:expected_rows) { [[a_string_matching('John'), a_string_matching(/lennon/i), 40]] }

          specify { full_match }
        end
      end

      context 'when the row is given as a hash' do
        context 'when the number of columns differs' do
          let(:expected_rows) { [john.dup.tap { |j| j[:ono] = 'yoko' }] }

          specify { full_match_fails }
          specify { partial_match_fails }
        end

        context 'when the actual and expected have are different' do
          let(:expected_rows) { [john.dup.tap { |j| j[:first_name] = 'yoko' }] }

          specify { full_match_fails }
          specify { partial_match_fails }
        end

        context 'when the actual and expected rows are equal' do
          let(:expected_rows) { [john] }

          specify { full_match }
          specify { partial_match }
        end

        context 'when matching a subset of columns' do
          let(:expected_rows) { [{first_name: john[:first_name]}] }

          specify { full_match_fails }
          specify { partial_match }
        end
      end
    end
  end
end
