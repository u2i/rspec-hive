# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Hive::QueryBuilder::RowTransformer do
  let(:transformer) { described_class.new(schema, missing_column_strategy) }
  let(:schema) do
    RBHive::TableSchema.new('table_name', nil) do
      column :col1, :string
      column :col2, :string
    end
  end
  let(:column) { schema.instance_variable_get(:@columns).last }
  let(:partition) { double }
  let(:missing_column_strategy) { double }

  describe '#transform' do
    subject { transformer.transform(row) }

    let(:row) { {col1: real_value} }
    let(:real_value) { 'col1' }
    let(:fake_value) { 'lorem' }
    let(:expected_row) { [real_value, fake_value] }

    before { allow(missing_column_strategy).to receive(:missing).with(column).and_return(fake_value) }

    it 'fills missing fields' do
      expect(subject[1]).to eq(fake_value)
    end

    it 'uses defined fields' do
      expect(subject[0]).to eq(real_value)
    end

    it 'returns valid Rows' do
      expect(subject).to eq(expected_row)
    end
  end
end
