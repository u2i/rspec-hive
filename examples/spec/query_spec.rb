require_relative 'spec_helper'
require_relative '../lib/query'
require 'rspec/hive/query_builder_helper'

RSpec.describe Query do
  include RSpec::Hive::WithHiveConnection
  include RSpec::Hive::QueryBuilderHelper

  subject { described_class.new }

  let(:schema) { subject.table_schema }

  describe 'hive query' do
    let(:input_data) do
      [
        ['Mikolaj', 'Cos', 1.23, 1],
        ['Wojtek', 'Cos', 3.76, 2]
      ]
    end

    before do
      connection.execute(schema.create_table_statement)
      into_hive(schema).insert(*input_data).execute
    end

    it 'query returns one row' do
      query = "SELECT * FROM `#{subject.table_name}` WHERE amount > 3.2"
      query_result = connection.fetch(query)

      expected_result_set = [
        [a_string_matching('Wojtek'), 'Cos', be_within(0.01).of(3.76)]
      ]

      expect(query_result).to match_result_set(expected_result_set)
    end

    it 'query returns one row 2' do
      query = "SELECT * FROM `#{subject.table_name}` WHERE amount < 3.2"
      query_result = connection.fetch(query)

      expected_result_set = [
        {name: 'Mikolaj',
         address: 'Cos',
         amount: be_within(0.01).of(1.23)
      }
      ]
      expect(query_result).to match_result_set(expected_result_set)
    end
  end

  describe 'use mocked rows' do
    before do
      connection.execute(schema.create_table_statement)
      into_hive(schema).insert(row1, row2).with_stubbing.execute
    end

    let(:row1) { {name: 'Michal'} }
    let(:row2) { {name: 'Wojtek'} }

    it 'mocks unspecified values' do
      query = "SELECT * FROM `#{subject.table_name}`"
      result = connection.fetch(query)

      aggregate_failures do
        names = result.map { |row| row[:name] }
        expect(names).to contain_exactly('Michal', 'Wojtek')

        result.each do |row|
          expect(row[:address]).not_to be_empty
          expect(row[:address]).not_to eq('\N')
          expect(row[:amount]).not_to be_nil
          expect(row[:amount]).not_to eq('\N')
        end
      end
      #
      # into_hive(schema).insert(name: 'Michal').partition(country_code: 'us')
      #
      # # Given
      # part = into_hive(schema).partition(country_code: 'us').with_mocking
      # i = part.insert([{name: 'Michal'}, {amount: 12.324}])
      # i2 = part.insert([{name: 'Michal'}, {amount: 12.324}])
      # i.execute(connection)
      # i2.execute(connection)
      #
      # # When
      # row = query.fetch(query_statement).first
      #
      # # Then
      # expect(row).to match_row({})
      # expect(row).to match_row({}).with_schema(schema)
      # expect(row).to match_row([]).with_schema()
      # expect(row).to match_row([])
      #
      # # When
      # rows = query.fetch(query_statement)
      #
      # # Then
      # expect(rows).to match_rows().with_schema(schema)
      # expect(rows).to match_rows().with_schema(schema).ordered
      # expect(rows).to match_rows().with_schema(schema).unordered
      # expect(rows).to match_rows()
      #
      # into_hive(schema).with_mocking.insert(name: 'Michal').partition(country_code: 'us')
      # into(schema).with_mocking.insert(name: 'Michal').partition(country_code: 'us')
      #
      # with_hive_connection do
      # end
      #
      # schema1
      # schema2
      # table11 = [{name: 'asd'}]
      # table12 = [{name: 'asd'}]
      # table2 = [{name2: 'asd'}]
      # partition11 = {country_code: 'us'}
      # partition12 = {country_code: 'it'}
      #
      # into_hive(schema1).partition(partition11).insert(table11).execute(connection)
      # into_hive(schema1).partition(partition11).insert(table11)
      #
      # setup_table(connection, schema1, partition11 => [table11])
    end
  end
end
