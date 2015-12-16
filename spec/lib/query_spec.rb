require_relative '../../lib/connector'
require 'spec_helper'
require_relative '../../lib/query'


module WithHiveConnection
  def self.extended(mod)
    mod.let(:hive) { Connector.new }

    mod.let(:connection) { hive.start_connection }

    mod.after(:all) do
      hive.stop_connection(connection) unless hive && connection
    end
  end
end

describe Query do
  extend WithHiveConnection

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
        hive.load_into_table(subject.table_name, input_data)
    end

    it 'query returns one row' do
      # #when
      # subject.run_hive_query(connection)


      # #then
      # require 'pry'; binding.pry
      expect(connection.fetch("SELECT * FROM `#{subject.table_name}` WHERE amount > 3.2").first.values).to eq(['Wojtek', 'Cos', 3.76])


      # expect(subject.run_hive_query(hive_connection)).to eq([['Wojtek', 'Cos', 3.76]])
    end

    it 'query returns one row 2' do
      #given

      # #when
      # subject.run_hive_query(connection)

      # #then
      expect(connection.fetch("SELECT * FROM `#{subject.table_name}` WHERE amount < 3.2").first.values).to eq(['Mikolaj', 'Cos', 1.23])

      # expect(subject.run_hive_query(hive_connection)).to eq([['Wojtek', 'Cos', 3.76]])
    end
  end
end

