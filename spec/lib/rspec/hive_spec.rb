# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Hive do
  describe '.connector' do
    subject { described_class.connector }

    it { is_expected.to be_an_instance_of(RSpec::Hive::Connector) }
  end

  describe '.configure' do
    let(:expected_host) { '127.0.0.1' }
    let(:expected_port) { '10000' }
    let(:expected_host_shared_directory_path) { '/Users/Shared/tmp/spec-files' }
    let(:expected_docker_shared_directory_path) { '/tmp/spec-tmp-files' }

    context 'when file name is provided' do
      subject(:configure) { described_class.configure(file_name) }

      let(:file_name) { 'test.yaml' }
      let(:configuration_mock) do
        instance_double(
          described_class::Configuration,
          host: expected_host,
          port: expected_port,
          host_shared_directory_path: expected_host_shared_directory_path,
          docker_shared_directory_path: expected_docker_shared_directory_path
        )
      end

      before { allow(RSpec::Hive::Configuration).to receive(:new).with(file_name) { configuration_mock } }

      specify do
        expect(described_class).to receive(:new_configuration).with(file_name) { configuration_mock }
        configure
      end
      its(:host) { is_expected.to eq(expected_host) }
      its(:port) { is_expected.to eq(expected_port) }
      its(:host_shared_directory_path) { is_expected.to eq(expected_host_shared_directory_path) }
      its(:docker_shared_directory_path) { is_expected.to eq(expected_docker_shared_directory_path) }
    end

    context 'when block is given' do
      subject do
        described_class.configure do |config|
          config.host = expected_host
          config.port = expected_port
          config.host_shared_directory_path =
            expected_host_shared_directory_path
          config.docker_shared_directory_path =
            expected_docker_shared_directory_path
        end
      end

      its(:host) { is_expected.to eq(expected_host) }
      its(:port) { is_expected.to eq(expected_port) }
      its(:host_shared_directory_path) { is_expected.to eq(expected_host_shared_directory_path) }
      its(:docker_shared_directory_path) { is_expected.to eq(expected_docker_shared_directory_path) }
    end
  end
end
