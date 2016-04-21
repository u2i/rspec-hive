require 'spec_helper'
require_relative 'query'
require_relative 'config_helper'
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
      connection.execute(subject.table_schema.create_table_statement)
      into_hive(subject.table_schema).insert(*input_data).execute
    end

    it 'query returns one row' do
      query = "SELECT * FROM `#{subject.table_name}` WHERE amount > 3.2"
      query_result = connection.fetch(query).first.values

      expected_row = [
        a_string_matching('Wojtek'),
        a_string_matching('Cos'),
        a_string_matching(/3\.7.*/),
      ]
      expect(query_result).to contain_exactly(*expected_row)
    end

    it 'query returns one row 2' do
      query = "SELECT * FROM `#{subject.table_name}` WHERE amount < 3.2"
      query_result = connection.fetch(query).first.values

      expected_row = [
        a_string_matching('Mikolaj'),
        a_string_matching('Cos'),
        a_string_matching(/1\.2.*/)
      ]
      expect(query_result).to contain_exactly(*expected_row)
    end
  end

  describe 'use mocked rows' do
    before do
      connection.execute(subject.table_schema.create_table_statement)
      into_hive(subject.table_schema).insert(row1, row2).with_stubbing.execute
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
          expect(row[:address]).not_to be_nil
          expect(row[:address]).not_to eq('\N')
          expect(row[:amount]).to match(/\d+\.\d+/)
        end
      end
      #
      # into_hive(subject.table_schema).insert(name: 'Michal').partition(country_code: 'us')
      #
      # # Given
      # part = into_hive(subject.table_schema).partition(country_code: 'us').with_mocking
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
      # into_hive(subject.table_schema).with_mocking.insert(name: 'Michal').partition(country_code: 'us')
      # into(subject.table_schema).with_mocking.insert(name: 'Michal').partition(country_code: 'us')
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
