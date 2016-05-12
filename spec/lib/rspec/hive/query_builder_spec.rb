require 'spec_helper'

RSpec.describe RSpec::Hive::QueryBuilder do
  let(:connection) { instance_double(RBHive::TCLIConnection) }
  let(:connection_delegator) { RSpec::Hive::ConnectionDelegator.new(connection, {}) }
  let(:query_builder) { described_class.new(schema, connection_delegator) }
  let(:schema) { double }

  describe '#execute' do
    subject { builder.execute }

    context 'when has no partition' do
      before do
        expect(connection_delegator).to receive(:load_into_table).with(schema, expected_rows)
      end

      let(:schema) do
        RBHive::TableSchema.new('table_name', nil) do
          column :col1, :string
          column :col2, :int
        end
      end

      context 'when no data stubbing' do
        context 'when single row is passed' do
          let(:builder) { query_builder.insert(row1) }
          let(:row1) { ['col1', 343] }
          let(:expected_rows) { [row1] }

          it 'loads single row' do
            subject
          end
        end

        context 'when single incomplete row is passed' do
          let(:builder) { query_builder.insert(row1) }
          let(:row1) { ['col1'] }
          let(:expected_rows) { [row1 << '\N'] }

          it 'fills missing columns with \N' do
            subject
          end
        end

        context 'when multiple rows are passed' do
          let(:builder) { query_builder.insert(row1, row2) }
          let(:row1) { ['col1', 343] }
          let(:row2) { ['col1', 123] }
          let(:expected_rows) { [row1, row2] }

          it 'loads multiple rows' do
            subject
          end
        end

        context 'when row with single column is passed' do
          let(:builder) { query_builder.insert(row1) }
          let(:row1) { {col1: 'col1'} }
          let(:expected_rows) { [['col1', '\N']] }

          it 'fills missing columns with \N' do
            subject
          end
        end

        context 'when multiple rows with single columns are passed' do
          let(:builder) { query_builder.insert(row1, row2) }
          let(:row1) { {col1: 'col1'} }
          let(:row2) { {col2: 345} }
          let(:expected_rows) { [['col1', '\N'], ['\N', 345]] }

          it 'fills missing columns with \N for each row' do
            subject
          end
        end
      end

      context 'when has data stubbing' do
        context 'when single row is passed' do
          let(:builder) { query_builder.with_stubbing.insert(row1) }
          let(:row1) { ['col1', 343] }
          let(:expected_rows) { [row1] }

          it 'loads single row' do
            subject
          end
        end

        context 'when single incomplete row is passed' do
          let(:builder) { query_builder.insert(row1) }
          let(:row1) { ['col1'] }
          let(:expected_rows) { [row1 << a_string_matching(/\d+/)] }

          it 'fills missing column with data matching column type' do
            subject
          end
        end

        context 'when multiple rows are passed' do
          let(:builder) { query_builder.with_stubbing.insert(row1, row2) }
          let(:row1) { ['col1', 343] }
          let(:row2) { ['col1', 123] }
          let(:expected_rows) { [row1, row2] }

          it 'loads multiple rows' do
            subject
          end
        end

        context 'when row with single column is passed' do
          let(:builder) { query_builder.with_stubbing.insert(row1) }
          let(:row1) { {col1: 'col1'} }
          let(:expected_rows) { [['col1', a_string_matching(/\d+/)]] }

          it 'fills missing columns with data matching column type' do
            subject
          end
        end

        context 'when multiple rows with single columns are passed' do
          let(:builder) { query_builder.with_stubbing.insert(row1, row2) }
          let(:row1) { {col1: 'col1'} }
          let(:row2) { {col2: 345} }
          let(:expected_rows) { [['col1', a_string_matching(/\d+/)], [a_string_matching(/\S+/), 345]] }

          it 'fills missing columns with data matching column type for each row' do
            subject
          end
        end
      end
    end

    context 'when has a partition' do
      let(:schema) do
        RBHive::TableSchema.new('table_name', nil) do
          column :col1, :string
          column :col2, :integer
          partition :dt, :int
        end
      end

      before do
        expect(connection_delegator).
          to receive(:load_into_table).with(schema, expected_rows, partitions)
      end

      context 'when no data stubbing' do
        context 'when single row is passed' do
          let(:builder) { query_builder.insert(row1).partition(partitions) }
          let(:row1) { ['col1', 343] }
          let(:partitions) { {dt: :int} }
          let(:expected_rows) { [row1] }

          it 'loads single row' do
            subject
          end
        end
      end
    end
  end
end
