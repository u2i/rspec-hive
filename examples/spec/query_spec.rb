# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/query'

RSpec.describe Query do
  include RSpec::Hive::WithHiveConnection
  include RSpec::Hive::QueryBuilderHelper

  subject { described_class.new }

  let(:schema) { subject.table_schema }

  before { connection.execute(schema.create_table_statement) }

  context 'if we have a partition' do
    let(:schema) do
      RBHive::TableSchema.new('partitioned_people', nil, line_sep: '\n', field_sep: ';') do
        column :name, :string
        column :address, :string
        column :amount, :float
        partition :dth, :int
      end
    end
    let(:input_data) do
      [
        ['Mikolaj', 'Cos', 1.23, 1],
        ['Wojtek', 'Cos', 3.76, 2]
      ]
    end
    let(:dth) { '2016042210' }
    let(:query) { "SELECT * FROM `#{schema.name}` WHERE amount > 3.2" }
    let(:query_result) { connection.fetch(query) }
    let(:expected_result_array) do
      [[a_string_matching('Wojtek'), 'Cos', be_within(0.01).of(3.76), dth]]
    end

    before do
      connection.execute("ALTER TABLE #{schema.name} ADD PARTITION (dth='#{dth}')")
      into_hive(schema).insert(*input_data).partition(dth: dth).execute
    end

    it 'returns Wojtek' do
      expect(query_result).to match_result_set(expected_result_array)
    end
  end

  context 'without stubbing strategy' do
    let(:input_data) do
      [
        ['Mikolaj', 'Cos', 1.23, 1],
        ['Wojtek', 'Cos', 3.76, 2]
      ]
    end
    let(:query_result) { connection.fetch(query) }

    before { into_hive(schema).insert(*input_data).execute }

    context 'when querying for amount > 3.2' do
      let(:query) { "SELECT * FROM `#{subject.table_name}` WHERE amount > 3.2" }
      let(:expected_result_array) do
        [
          [a_string_matching('Wojtek'), 'Cos', be_within(0.01).of(3.76)]
        ]
      end

      it 'returns Wojtek' do
        expect(query_result).to match_result_set(expected_result_array)
      end
    end
  end

  context 'with stubbing strategy' do
    let(:input_data) { [{name: 'Michal'}, {name: 'Wojtek'}] }
    let(:query_result) { connection.fetch(query) }

    before { into_hive(schema).insert(*input_data).with_stubbing.execute }

    context "when querying for name = 'Wojtek'" do
      let(:query) do
        "SELECT * FROM `#{subject.table_name}` WHERE name='Wojtek'"
      end
      let(:expected_result_array) do
        [
          ['Wojtek', a_kind_of(String), a_kind_of(Float)]
        ]
      end

      it 'returns Wojtek' do
        expect(query_result).to match_result_set(expected_result_array)
      end
    end

    context 'when querying for name = Michal' do
      let(:query) do
        "SELECT * FROM `#{subject.table_name}` WHERE name='Michal'"
      end
      let(:expected_result_hash) { [{name: 'Michal'}] }

      it 'returns Michal' do
        expect(query_result).to match_result_set(expected_result_hash).partially
      end
    end
  end
end
