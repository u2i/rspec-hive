require 'spec_helper'
require_relative '../../lib/connector'

describe Connector do
  xit do
    subject.create_table
    expect(subject.show_tables).to eq(['people'])
  end

  describe 'with isolated-random-named databases' do

    xit 'generates two different database names' do
      connector1 = Connector.new
      connector2 = Connector.new

      expect(connector1.db_name).not_to eq(connector2.db_name)
    end

    xit 'shows databases' do
      connector = Connector.new

      expect(connector.show_databases).to include({database_name: connector.db_name})
    end
  end


  # describe 'hive query' do
  #   let(:input_data) do
  #     [
  #       ['A', 1],
  #       ['B', 2]
  #     ]
  #   end
  #   let(:table_name) { 'table' }
  #
  #   before { insert_data_into_table(table_name, input_data) }
  #
  #   it 'query returns one row' do
  #     expect(hive.fetch("SELECT * FROM #{table} WHERE C2 > 1")).to eq([['B', 2]])
  #   end
  # end
end
