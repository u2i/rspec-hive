require 'spec_helper'
require 'rspec/hive/query_builder/rows'

RSpec.describe RSpec::Hive::QueryBuilder::Rows do
  let(:hive_rows) { described_class.new(schema, rows, partition) }
  let(:schema) do
    RBHive::TableSchema.new('table_name', nil) do
      column :col1, :string
      column :col2, :string
    end
  end
  let(:partition) { double }

  describe '#values' do
    subject { hive_rows.values }

    let(:rows) { [row1, row2] }
    let(:row1) { %w(col1 col2) }

    context 'when row size matches schema' do
      let(:row2) { %w(val1 val2) }

      it 'returns all rows' do
        expect(subject).to contain_exactly(row1, row2)
      end
    end

    context 'when row contains more columns than schema' do
      let(:row2) { %w(val1 val2 val3) }

      it 'raises error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when row contains less columns than schema' do
      let(:row2) { %w(val1) }

      it 'raises error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
