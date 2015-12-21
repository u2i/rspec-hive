require 'spec_helper'
require 'hive_tests'

describe Connector do
  xit do
    subject.create_table
    expect(subject.show_tables).to eq(['people'])
  end

  describe 'with isolated-random-named databases' do
    it 'generates two different database names' do
      connector1 = Connector.new
      connector2 = Connector.new

      expect(connector1.db_name).not_to eq(connector2.db_name)
    end

    xit 'shows databases' do
      connector = Connector.new

      expect(connector.show_databases).to include({database_name: connector.db_name})
    end
  end
end
