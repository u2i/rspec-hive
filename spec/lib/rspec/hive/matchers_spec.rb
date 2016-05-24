require 'spec_helper'
require 'rspec/hive/query_builder_helper'

RSpec.describe 'match_result_set' do
  include RSpec::Hive::QueryBuilderHelper

  let(:john) { {first_name: 'John', last_name: 'Lennon', age: 40} }
  let(:paul) { {first_name: 'Paul', last_name: 'McCartney', age: 73} }

  let(:full_match) { expect(actual_rows).to match_result_set(expected_rows) }
  let(:unordered_match) { expect(actual_rows).to match_result_set(expected_rows).unordered }
  let(:partial_match) { expect(actual_rows).to match_result_set(expected_rows).partially }
  let(:partial_unordered_match) { expect(actual_rows).to match_result_set(expected_rows).partially.unordered }

  let(:full_match_fails) { expect(actual_rows).not_to match_result_set(expected_rows) }
  let(:unordered_match_fails) { expect(actual_rows).not_to match_result_set(expected_rows).unordered }
  let(:partial_match_fails) { expect(actual_rows).not_to match_result_set(expected_rows).partially }
  let(:partial_unordered_match_fails) { expect(actual_rows).not_to match_result_set(expected_rows).partially.unordered }

  let(:partial_match_raises_error) do
    error_message = "Can't use partially matcher with Arrays"
    aggregate_failures do
      expect { partial_match }.to raise_error(ArgumentError, error_message)
      expect { partial_match_fails }.to raise_error(ArgumentError, error_message)
      expect { partial_unordered_match }.to raise_error(ArgumentError, error_message)
      expect { partial_unordered_match_fails }.to raise_error(ArgumentError, error_message)
    end
  end

  context 'when the expected set has only one row' do
    context 'but the actual set has more rows' do
      let(:actual_rows) { [john, paul] }

      context 'when the row is given as an array' do
        let(:expected_rows) { [john.values] }

        specify { full_match_fails }
        specify { unordered_match_fails }
        specify { partial_match_raises_error }
      end

      context 'when the row is given as a hash' do
        let(:expected_rows) { [john] }

        specify { full_match_fails }
        specify { unordered_match_fails }
        specify { partial_match_fails }
        specify { partial_unordered_match_fails }
      end
    end

    context 'and the actual set has one row' do
      let(:actual_rows) { [john] }

      context 'when the row is given as an array' do
        context 'when the number of columns differs' do
          let(:expected_rows) { [john.values << 'yoko'] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match_raises_error }
        end

        context 'when the actual and expected have are different' do
          let(:expected_rows) { [paul.values] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match_raises_error }
        end

        context 'when the actual and expected rows are equal' do
          let(:expected_rows) { [john.values] }

          specify { full_match }
          specify { unordered_match }
          specify { partial_match_raises_error }
        end

        context 'when the actual and expected rows are equal with rspec matchers' do
          let(:expected_rows) { [[a_string_matching('John'), a_string_matching(/lennon/i), 40]] }

          specify { full_match }
          specify { unordered_match }
          specify { partial_match_raises_error }
        end
      end

      context 'when the row is given as a hash' do
        context 'when the number of columns differs' do
          let(:expected_rows) { [john.dup.tap { |j| j[:ono] = 'yoko' }] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match_fails }
          specify { partial_unordered_match_fails }
        end

        context 'when the actual and expected have are different' do
          let(:expected_rows) { [john.dup.tap { |j| j[:first_name] = 'yoko' }] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match_fails }
          specify { partial_unordered_match_fails }
        end

        context 'when the actual and expected rows are equal' do
          let(:expected_rows) { [john] }

          specify { full_match }
          specify { unordered_match }
          specify { partial_match }
          specify { partial_unordered_match }
        end

        context 'when matching a subset of columns' do
          let(:expected_rows) { [{first_name: john[:first_name]}] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match }
          specify { partial_unordered_match }
        end
      end
    end
  end

  context 'when the expected set has multiple rows' do
    let(:george) { {first_name: 'George', last_name: 'Harrison', age: 58} }

    context 'and the actual set has the same number of rows' do
      let(:actual_rows) { [george, paul, john] }

      context 'when the row is given as an array' do
        context 'when rows are returned in order' do
          let(:expected_rows) { [george.values, paul.values, john.values] }

          specify { full_match }
          specify { unordered_match }
          specify { partial_match_raises_error }
        end

        context 'when rows are returned in different order' do
          let(:expected_rows) { [paul.values, john.values, george.values] }

          specify { full_match_fails }
          specify { unordered_match }
          specify { partial_match_raises_error }
        end
      end

      context 'when the row is given as a hash' do
        context 'when matching all columns' do
          context 'when rows are returned in order' do
            let(:expected_rows) { [george, paul, john] }

            specify { full_match }
            specify { unordered_match }
            specify { partial_match }
            specify { partial_unordered_match }
          end

          context 'when rows are returned in different order' do
            let(:expected_rows) { [paul, john, george] }

            specify { full_match_fails }
            specify { unordered_match }
            specify { partial_match_fails }
            specify { partial_unordered_match }
          end
        end

        context 'when matching a subset of columns' do
          let(:expected_rows) { members.map { |member| {age: member[:age]} } }

          context 'when rows are returned in order' do
            let(:members) { [george, paul, john] }

            specify { full_match_fails }
            specify { unordered_match_fails }
            specify { partial_match }
            specify { partial_unordered_match }
          end

          context 'when rows are returned in different order' do
            let(:members) { [john, paul, george] }

            specify { full_match_fails }
            specify { unordered_match_fails }
            specify { partial_match_fails }
            specify { partial_unordered_match }
          end
        end
      end
    end

    context 'and the expected set has more rows' do
      let(:ringo) { {first_name: 'Richard', last_name: 'Starkey', age: 75} }
      let(:actual_rows) { [paul, john] }

      context 'when the row is given as an array' do
        context 'when rows are returned in order' do
          let(:expected_rows) { [ringo.values, paul.values, john.values] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match_raises_error }
        end

        context 'when rows are returned in different order' do
          let(:expected_rows) { [paul.values, john.values, ringo.values] }

          specify { full_match_fails }
          specify { unordered_match_fails }
          specify { partial_match_raises_error }
        end
      end

      context 'when the row is given as a hash' do
        context 'when matching all columns' do
          context 'when rows are returned in order' do
            let(:expected_rows) { [ringo, paul, john] }

            specify { full_match_fails }
            specify { unordered_match_fails }
            specify { partial_match_fails }
            specify { partial_unordered_match_fails }
          end

          context 'when rows are returned in different order' do
            let(:expected_rows) { [paul, john, ringo] }

            specify { full_match_fails }
            specify { unordered_match_fails }
            specify { partial_match_fails }
            specify { partial_unordered_match_fails }
          end
        end

        context 'when matching a subset of columns' do
          let(:expected_rows) { members.map { |member| {age: member[:age]} } }

          context 'when rows are returned in order' do
            let(:members) { [ringo, paul, john] }

            specify { full_match_fails }
            specify { unordered_match_fails }
            specify { partial_match_fails }
            specify { partial_unordered_match_fails }
          end

          context 'when rows are returned in different order' do
            let(:members) { [john, paul, ringo] }

            specify { full_match_fails }
            specify { unordered_match_fails }
            specify { partial_match_fails }
            specify { partial_unordered_match_fails }
          end
        end
      end
    end
  end
end
