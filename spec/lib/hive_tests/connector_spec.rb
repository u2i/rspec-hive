require 'spec_helper'

describe HiveTests::Connector do
  describe '#start_connection' do
    let(:tcli_connection) { double(RBHive::TCLIConnection) }
    let(:connection_delegator) { double(HiveTests::ConnectionDelegator) }
    let(:db_name) { 'test' }
    let(:host) { '127.0.0.1' }
    let(:port) { '10000' }
    let(:options_mock) { double('options') }
    let(:configuration) { double(HiveTests::Configuration, host: host, port: port) }

    before do
      allow(subject).to receive(:connection_options) { options_mock }
      expect(RBHive::TCLIConnection).to receive(:new).with(host, port, options_mock) { tcli_connection }
      expect(HiveTests::ConnectionDelegator).to receive(:new).with(tcli_connection, configuration) { connection_delegator }

      expect(connection_delegator).to receive(:open).once
      expect(connection_delegator).to receive(:open_session).once
      expect(connection_delegator).to receive(:create_database).once
      expect(connection_delegator).to receive(:use_database).once
    end

    subject { described_class.new(configuration, db_name) }

    it do
      expect(subject.start_connection).to equal(connection_delegator)
    end
  end
end
