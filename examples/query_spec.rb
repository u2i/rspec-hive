require 'spec_helper'
require_relative 'query'
require_relative 'config_helper'

describe Query do
  include HiveTests::WithHiveConnection

  subject { described_class.new }

  describe 'hive query' do
    let(:input_data) do
      [
        ['Mikolaj', 'Cos', 1.23],
        ['Wojtek', 'Cos', 3.76]
      ]
    end

    before do
      connection.execute(subject.table_schema.create_table_statement)
      connection.load_into_table(subject.table_name, input_data)
    end

    it 'query returns one row' do
      query = "SELECT * FROM `#{subject.table_name}` WHERE amount > 3.2"
      query_result = connection.fetch(query).first.values
      expect(query_result).to contain_exactly(
        a_string_matching('Wojtek'),
        a_string_matching('Cos'),
        a_string_matching(/3\.7.*/))
    end

    it 'query returns one row 2' do
      query = "SELECT * FROM `#{subject.table_name}` WHERE amount < 3.2"
      query_result = connection.fetch(query).first.values
      expect(query_result).to contain_exactly(
        a_string_matching('Mikolaj'),
        a_string_matching('Cos'),
        a_string_matching(/1\.2.*/))
    end
  end
end
