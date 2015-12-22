require 'spec_helper'

describe HiveTests::ConnectionDelegator do
  describe '#load_into_table' do
    let(:host_shared_directory_path) { '/tmp/host' }
    let(:docker_file_path) { '/tmp/docked/test_file' }
    let(:config) { double(HiveTests::Configuration,
                          host_shared_directory_path: host_shared_directory_path) }
    let(:connection) { double('Connection') }
    let(:file_mock) { double(Tempfile) }

    let(:table_name) { 'test_table' }
    let(:values) { ['a', 'b', 1] }

    before do
      expect(Tempfile).to receive(:open).with(table_name, host_shared_directory_path).and_yield(file_mock)
      expect(subject).to receive(:translate_to_docker_path).with(file_mock) { docker_file_path }
      expect(subject).to receive(:write_values_to_file).with(file_mock, values).once
      expect(subject).to receive(:load_file_to_hive_table).with(table_name, docker_file_path).once
    end

    subject { described_class.new(connection, config) }

    it do
      subject.load_into_table(table_name, values)
    end
  end

  describe '#write_values_to_file' do
    let(:file) { StringIO.new }
    let(:values) { [['a', 'b', 1],
                    ['aa', 'bb', 22]] }
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
    let(:execute_text) { "load data local inpath '/tmp/test' into table test_table" }

    before do
      expect(connection).to receive(:execute).with(execute_text)
    end

    subject { described_class.new(connection, config)}

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
    let(:config) { double(HiveTests::Configuration,
                          docker_shared_directory_path: docker_shared_directory_path) }

    before do
      expect(file_mock).to receive(:path) { file_host_path }
    end

    subject { described_class.new(connection, config) }

    it do
      expect(subject.send(:translate_to_docker_path, file_mock)).to eq(expected_file_path)
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
end