# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Hive::QueryBuilderHelper do
  let(:connection) { double }
  let(:schema) { double }
  let(:dummy_class) { double }

  before { dummy_class.extend(described_class) }

  describe '#into_hive' do
    context 'when no connection has been defined' do
      it 'raises and error' do
        expect { dummy_class.into_hive(schema) }.
          to raise_error(RSpec::Hive::QueryBuilderHelper::HiveConnectionNotFound).
          with_message('Include WithHiveConnection')
      end
    end

    context 'when RBhive connection has been given' do
      subject { dummy_class.into_hive(schema) }

      let(:dummy_class) { double(connection: connection) }

      before do
        allow(connection).to receive(:is_a?).with(RBHive::TCLIConnection).and_return(true)
      end

      it 'returns a query_builder' do
        expect(subject).to be_a_kind_of(RSpec::Hive::QueryBuilder)
      end
    end

    context 'when ConnectionDelegator has been given' do
      subject { dummy_class.into_hive(schema) }

      let(:dummy_class) { double(connection: connection) }

      before do
        allow(connection).to receive(:is_a?).with(RBHive::TCLIConnection).and_return(false)
        allow(connection).to receive(:is_a?).with(RSpec::Hive::ConnectionDelegator).and_return(true)
      end

      it 'returns a query_builder' do
        expect(subject).to be_a_kind_of(RSpec::Hive::QueryBuilder)
      end
    end
  end
end
