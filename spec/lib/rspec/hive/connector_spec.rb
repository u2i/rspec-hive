require 'spec_helper'

describe RSpec::Hive::Connector do
  describe '#start_connection' do
    let(:tcli_connection) { double(RBHive::TCLIConnection) }
    let(:connection_delegator) { double(RSpec::Hive::ConnectionDelegator) }
    let(:host) { '127.0.0.1' }
    let(:port) { '10000' }
    let(:options_mock) { double('options') }
    let(:hive_options) do
      {'hive.exec.dynamic.partition' => 'true',
       'hive.exec.dynamic.partition.mode' => 'nonstrict',
       'hive.exec.max.dynamic.partitions.pernodexi' => '100000',
       'hive.exec.max.dynamic.partitions' => '100000',
       'mapred.child.java.opts' => '-Xmx2048m'}
    end
    let(:configuration) do
      double(
        RSpec::Hive::Configuration,
        host: host,
        port: port,
        hive_options: hive_options
      )
    end

    context 'when db_name is provided' do
      let(:db_name) { 'test' }

      before do
        allow(subject).to receive(:connection_options) { options_mock }
        expect(RBHive::TCLIConnection).to receive(:new).
          with(host, port, options_mock) { tcli_connection }
        expect(RSpec::Hive::ConnectionDelegator).to receive(:new).
          with(tcli_connection, configuration) { connection_delegator }

        expect(connection_delegator).to receive(:open).once
        expect(connection_delegator).to receive(:open_session).once
        expect(connection_delegator).to receive(:switch_database).
          with(db_name).once
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.dynamic.partition=true;')
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.dynamic.partition.mode=nonstrict;')
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.max.dynamic.partitions.pernodexi=100000;')
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.max.dynamic.partitions=100000;')
        expect(connection_delegator).to receive(:execute).with('SET mapred.child.java.opts=-Xmx2048m;')
        allow(configuration).to receive_message_chain(:logger, :info)
      end

      subject { described_class.new(configuration) }

      it do
        expect(subject.start_connection(db_name)).to equal(connection_delegator)
      end
    end

    context 'when db_name is not provided' do
      let(:db_random_name) { 'rand123' }

      before do
        allow(subject).to receive(:connection_options) { options_mock }
        expect(RSpec::Hive::DbName).to receive(:random_name) { db_random_name }
        expect(RBHive::TCLIConnection).to receive(:new).
          with(host, port, options_mock) { tcli_connection }
        expect(RSpec::Hive::ConnectionDelegator).to receive(:new).
          with(tcli_connection, configuration) { connection_delegator }

        expect(connection_delegator).to receive(:open).once
        expect(connection_delegator).to receive(:open_session).once
        expect(connection_delegator).to receive(:switch_database).
          with(db_random_name).once
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.dynamic.partition=true;')
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.dynamic.partition.mode=nonstrict;')
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.max.dynamic.partitions.pernodexi=100000;')
        expect(connection_delegator).to receive(:execute).with('SET hive.exec.max.dynamic.partitions=100000;')
        expect(connection_delegator).to receive(:execute).with('SET mapred.child.java.opts=-Xmx2048m;')
        allow(configuration).to receive_message_chain(:logger, :info)
      end

      subject { described_class.new(configuration) }

      it do
        expect(subject.start_connection).to equal(connection_delegator)
      end
    end
  end
end
