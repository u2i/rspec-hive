require 'spec_helper'

RSpec.describe RSpec::Hive::ConnectionDelegator do
  let(:day_column) { instance_double(RBHive::TableSchema::Column, name: :day, type: :string) }
  let(:dth_column) { instance_double(RBHive::TableSchema::Column, name: :dth, type: :int) }
  let(:hm_column) { instance_double(RBHive::TableSchema::Column, name: :hm, type: :int) }
  let(:country_column) { instance_double(RBHive::TableSchema::Column, name: :country, type: :string) }
  let(:table_name) { 'test_table' }
  let(:table_schema) { instance_double(RBHive::TableSchema, name: table_name) }

  describe '#load_into_table' do
    let(:host_shared_directory_path) { '/tmp/host' }
    let(:docker_file_path) { '/tmp/docked/test_file' }
    let(:config) do
      double(
        RSpec::Hive::Configuration,
        host_shared_directory_path: host_shared_directory_path
      )
    end
    let(:delimiter) { "\t" }
    let(:connection) { double('Connection') }
    let(:file_mock) { double(Tempfile) }

    let(:values) { ['a', 'b', 1] }

    before do
      table_schema.instance_variable_set(:@field_sep, delimiter)

      expect(Tempfile).to receive(:open).
        with(table_name, host_shared_directory_path).and_yield(file_mock)

      expect(subject).to receive(:docker_path).
        with(file_mock) { docker_file_path }

      expect(subject).to receive(:write_values_to_file).
        with(file_mock, values, "\t").once
    end

    context 'without partitions' do
      before do
        expect(subject).to receive(:load_file_to_hive_table).
          with(table_name, docker_file_path, nil).once

        expect(subject).not_to receive(:partition_clause)
      end

      subject { described_class.new(connection, config) }

      it do
        subject.load_into_table(table_schema, values)
      end
    end

    context 'with partitions' do
      subject { described_class.new(connection, config) }

      let(:partitions) { {day: '20160101', hm: '2020'} }
      let(:table_schema) { instance_double(RBHive::TableSchema, name: table_name, partitions: [day_column, hm_column]) }

      let(:partition_query) { "PARTITION(day='20160101',hm='2020')" }

      before do
        expect(subject).to receive(:load_file_to_hive_table).
          with(table_name, docker_file_path, partition_query).once
        expect(subject).to receive(:partition_clause).
          with(table_schema, partitions) { partition_query }
      end

      it do
        subject.load_into_table(table_schema, values, partitions)
      end
    end
  end

  describe '#load_partition' do
    subject { described_class.new(connection, config) }

    let(:config) { double('Config') }
    let(:connection) { double('Connection') }
    subject { described_class.new(connection, config) }
    let(:partitions) do
      [{dth: 'mon', country: 'us'}, {dth: 'tue', country: 'us'}]
    end
    let(:table_schema) { instance_double(RBHive::TableSchema, name: table_name, partitions: [day_column, hm_column, country_column]) }

    let(:partition_query) do
      "PARTITION(dth='mon',country='us') PARTITION(dth='tue',country='us')"
    end

    let(:executed_query) do
      "ALTER TABLE test_table ADD PARTITION(dth='mon',country='us') PARTITION(dth='tue',country='us')"
    end

    before do
      expect(subject).to receive(:partition_clause).with(table_schema, partitions) { partition_query }
      expect(connection).to receive(:execute).with(executed_query)
    end

    it do
      subject.load_partitions(table_schema, partitions)
    end
  end

  describe '#partition_clause' do
    let(:config) { double('Config') }
    let(:connection) { double('Connection') }

    context 'with single partition' do
      let(:partitions) { {day: 'tue', dth: '20160101'} }
      let(:table_schema) { instance_double(RBHive::TableSchema, partitions: [day_column, dth_column]) }
      let(:expected_partition_query) { "PARTITION(day='tue',dth=20160101)" }
      subject { described_class.new(connection, config) }

      it 'translates partition hash to single query' do
        expect(subject.send(:partition_clause, table_schema, partitions)).to eq(expected_partition_query)
      end
    end

    context 'with multiple partitions' do
      subject { described_class.new(connection, config) }

      let(:partitions) { [{day: 'mon', hm: '2020'}, {day: 'tue', hm: '2020'}, {day: 'mon', hm: '2030'}] }
      let(:table_schema) { instance_double(RBHive::TableSchema, partitions: [day_column, hm_column]) }

      let(:partition_query) do
        "PARTITION(day='mon',hm=2020) PARTITION(day='tue',hm=2020) PARTITION(day='mon',hm=2030)"
      end

      it 'translates partition hash to combined query' do
        expect(subject.send(:partition_clause, table_schema, partitions)).to eq(partition_query)
      end
    end
  end

  describe '#write_values_to_file' do
    subject { described_class.new(connection, config) }

    let(:file) { StringIO.new }
    let(:values) do
      [['a', 'b', 1],
       ['aa', 'bb', 22]]
    end
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:delimiter) { '|' }
    let(:expected_file_content) { "a|b|1\naa|bb|22\n" }

    it 'writes values to file in correct format' do
      subject.send(:write_values_to_file, file, values, delimiter)
      file.rewind
      expect(file.read).to eq(expected_file_content)
    end
  end

  describe '#load_file_to_hive_table' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:file_path) { '/tmp/test' }
    let(:execute_text) do
      "load data local inpath '/tmp/test' into table test_table"
    end

    before do
      expect(connection).to receive(:execute).with(execute_text)
    end

    it do
      subject.send(:load_file_to_hive_table, table_name, file_path)
    end
  end

  describe '#translate_to_docker_path' do
    subject { described_class.new(connection, config) }

    let(:file_mock) { double(File) }
    let(:file_name) { 'testfile' }
    let(:file_host_path) { '/tmp/host/testfile' }
    let(:expected_file_path) { '/tmp/docker/testfile' }

    let(:connection) { double('Connection') }
    let(:docker_shared_directory_path) { '/tmp/docker' }
    let(:config) do
      double(
        RSpec::Hive::Configuration,
        docker_shared_directory_path: docker_shared_directory_path
      )
    end

    before do
      expect(file_mock).to receive(:path) { file_host_path }
    end

    it do
      expect(subject.send(:docker_path, file_mock)).
        to eq(expected_file_path)
    end
  end

  describe '#show_tables' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:fetch_text) { 'SHOW TABLES' }

    before do
      expect(connection).to receive(:fetch).with(fetch_text)
    end

    it do
      subject.show_tables
    end
  end

  describe '#create_database' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:db_name) { 'test' }
    let(:fetch_text) { 'CREATE DATABASE IF NOT EXISTS `test`' }

    before do
      expect(connection).to receive(:execute).with(fetch_text)
    end

    it do
      subject.create_database(db_name)
    end
  end

  describe '#create_table' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:table_schema) { double('Table_schema') }
    let(:table_statement) { 'I AM TABLE STATEMENT' }

    before do
      expect(table_schema).to receive(:dup) { table_schema }
      expect(table_schema).to receive(:instance_variable_set).with(:@location, nil)
      expect(table_schema).to receive(:create_table_statement) { table_statement }
      expect(connection).to receive(:execute).with(table_statement)
    end

    it do
      subject.create_table(table_schema)
    end
  end

  describe '#use databaes' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:db_name) { 'test' }
    let(:fetch_text) { 'USE `test`' }

    before do
      expect(connection).to receive(:execute).with(fetch_text)
    end

    it do
      subject.use_database(db_name)
    end
  end

  describe '#drop_databse' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:db_name) { 'test' }
    let(:fetch_text) { 'DROP DATABASE `test`' }

    before do
      expect(connection).to receive(:execute).with(fetch_text)
    end

    it do
      subject.drop_database(db_name)
    end
  end

  describe '#show_databases' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:fetch_text) { 'SHOW DATABASES' }

    before do
      expect(connection).to receive(:fetch).with(fetch_text)
    end

    it do
      subject.show_databases
    end
  end

  describe '#switch database' do
    subject { described_class.new(connection, config) }

    let(:connection) { double('Connection') }
    let(:config) { double('Config') }

    let(:db_name) { 'test_db' }

    before do
      expect(subject).to receive(:create_database).once
      expect(subject).to receive(:use_database).once
    end

    it do
      subject.switch_database(db_name)
    end
  end
end
