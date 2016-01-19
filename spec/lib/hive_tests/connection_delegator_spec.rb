require 'spec_helper'

describe HiveTests::ConnectionDelegator do
  describe '#load_into_table' do
    let(:host_shared_directory_path) { '/tmp/host' }
    let(:docker_file_path) { '/tmp/docked/test_file' }
    let(:config) do
      double(
        HiveTests::Configuration,
        host_shared_directory_path: host_shared_directory_path
      )
    end
    let(:connection) { double('Connection') }
    let(:file_mock) { double(Tempfile) }

    let(:table_name) { 'test_table' }
    let(:values) { ['a', 'b', 1] }

    before do
      expect(Tempfile).to receive(:open).
        with(table_name, host_shared_directory_path).and_yield(file_mock)

      expect(subject).to receive(:docker_path).
        with(file_mock) { docker_file_path }

      expect(subject).to receive(:write_values_to_file).
        with(file_mock, values).once
    end

    context 'without partitions' do
      before do
        expect(subject).to receive(:load_file_to_hive_table).
          with(table_name, docker_file_path, nil).once

        expect(subject).not_to receive(:partition_clause)
      end

      subject { described_class.new(connection, config) }

      it do
        subject.load_into_table(table_name, values)
      end
    end

    context 'with partitions' do
      let(:partitions) { {day: '20160101', hm: '2020'} }
      let(:partition_query) { "PARTITION(day='20160101',hm='2020')" }
      before do
        expect(subject).to receive(:load_file_to_hive_table).
          with(table_name, docker_file_path, partition_query).once
        expect(subject).to receive(:partition_clause).
          with(partitions) { partition_query }
      end

      subject { described_class.new(connection, config) }

      it do
        subject.load_into_table(table_name, values, partitions)
      end
    end
  end

  describe '#load_partition' do
    let(:config) { double('Config') }
    let(:connection) { double('Connection') }

    let(:table_name) { 'test_table' }
    let(:partitions) do
      [{dth: 'mon', country: 'us'}, {dth: 'tue', country: 'us'}]
    end
    let(:partition_query) do
      "PARTITION(dth='mon',country='us') PARTITION(dth='tue',country='us')"
    end

    let(:executed_query) do
      "ALTER TABLE test_table ADD PARTITION(dth='mon',country='us') PARTITION(dth='tue',country='us')"
    end

    before do
      expect(subject).to receive(:partition_clause).
        with(partitions) { partition_query }
      expect(connection).to receive(:execute).with(executed_query)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.load_partitions(table_name, partitions)
    end
  end

  describe '#partition_clause' do
    let(:config) { double('Config') }
    let(:connection) { double('Connection') }

    context 'with single partition' do
      let(:partitions) { {day: '20160101', hm: '2020'} }
      let(:partition_query) { "PARTITION(day='20160101',hm='2020')" }

      subject { described_class.new(connection, config) }

      it 'translates partition hash to single query' do
        expect(subject.send(:partition_clause, partitions)).to eq(partition_query)
      end
    end

    context 'with multiple partitions' do
      let(:partitions) { [{day: 'mon', hm: '2020'}, {day: 'tue', hm: '2020'}, {day: 'mon', hm: '2030'}] }
      let(:partition_query) do
        "PARTITION(day='mon',hm='2020') PARTITION(day='tue',hm='2020') PARTITION(day='mon',hm='2030')"
      end

      subject { described_class.new(connection, config) }

      it 'translates partition hash to combined query' do
        expect(subject.send(:partition_clause, partitions)).to eq(partition_query)
      end
    end
  end

  describe '#write_values_to_file' do
    let(:file) { StringIO.new }
    let(:values) do
      [['a', 'b', 1],
       ['aa', 'bb', 22]]
    end
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:expected_file_content) { "a;b;1\naa;bb;22\n" }

    subject { described_class.new(connection, config) }
    it 'writes values to file in correct format' do
      subject.send(:write_values_to_file, file, values)
      file.rewind
      expect(file.read).to eq(expected_file_content)
    end
  end

  describe '#load_file_to_hive_table' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:table_name) { 'test_table' }
    let(:file_path) { '/tmp/test' }
    let(:execute_text) do
      "load data local inpath '/tmp/test' into table test_table"
    end

    before do
      expect(connection).to receive(:execute).with(execute_text)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.send(:load_file_to_hive_table, table_name, file_path)
    end
  end

  describe '#translate_to_docker_path' do
    let(:file_mock) { double(File) }
    let(:file_name) { 'testfile' }
    let(:file_host_path) { '/tmp/host/testfile' }
    let(:expected_file_path) { '/tmp/docker/testfile' }

    let(:connection) { double('Connection') }
    let(:docker_shared_directory_path) { '/tmp/docker' }
    let(:config) do
      double(
        HiveTests::Configuration,
        docker_shared_directory_path: docker_shared_directory_path
      )
    end

    before do
      expect(file_mock).to receive(:path) { file_host_path }
    end

    subject { described_class.new(connection, config) }

    it do
      expect(subject.send(:docker_path, file_mock)).
        to eq(expected_file_path)
    end
  end

  describe '#show_tables' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:fetch_text) { 'SHOW TABLES' }

    before do
      expect(connection).to receive(:fetch).with(fetch_text)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.show_tables
    end
  end

  describe '#create_database' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:db_name) { 'test' }
    let(:fetch_text) { 'CREATE DATABASE IF NOT EXISTS `test`' }

    before do
      expect(connection).to receive(:execute).with(fetch_text)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.create_database(db_name)
    end
  end

  describe '#create_table' do
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

    subject { described_class.new(connection, config) }

    it do
      subject.create_table(table_schema)
    end
  end

  describe '#use databaes' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:db_name) { 'test' }
    let(:fetch_text) { 'USE `test`' }

    before do
      expect(connection).to receive(:execute).with(fetch_text)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.use_database(db_name)
    end
  end

  describe '#drop_databse' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:db_name) { 'test' }
    let(:fetch_text) { 'DROP DATABASE `test`' }

    before do
      expect(connection).to receive(:execute).with(fetch_text)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.drop_database(db_name)
    end
  end

  describe '#show_databases' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }
    let(:fetch_text) { 'SHOW DATABASES' }

    before do
      expect(connection).to receive(:fetch).with(fetch_text)
    end

    subject { described_class.new(connection, config) }

    it do
      subject.show_databases
    end
  end

  describe '#switch database' do
    let(:connection) { double('Connection') }
    let(:config) { double('Config') }

    let(:db_name) { 'test_db' }

    before do
      expect(subject).to receive(:create_database).once
      expect(subject).to receive(:use_database).once
    end

    subject { described_class.new(connection, config) }

    it do
      subject.switch_database(db_name)
    end
  end
end
