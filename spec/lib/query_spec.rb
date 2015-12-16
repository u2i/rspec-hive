require 'spec_helper'
require_relative '../../lib/connector'
require_relative '../../lib/query'

describe Query do
  let(:hive) { Connector.new }
  subject { described_class.new }

  describe 'hive query' do
    let(:input_data) do
      [
        ['Mikolaj', 'Cos', 1.23],
        ['Wojtek', 'Cos', 3.76]
      ]
    end

    it 'query returns one row' do
      hive.connect do |connection|
        #given
        connection.execute(subject.table_schema.create_table_statement)
        hive.load_into_table(subject.table_name, input_data)

        #when
        subject.run_hive_query(connection)

        #then
        expect(connection.fetch("SELECT * FROM `#{subject.table_name}`")).to eq([['Wojtek', 'Cos', 3.76]])

        #      expect(subject.run_hive_query(hive_connection)).to eq([['Wojtek', 'Cos', 3.76]])
      end
    end
  end
end
