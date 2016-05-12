require 'spec_helper'

RSpec.describe RSpec::Hive do
  describe '.connector' do
    subject { described_class.connector }

    it { is_expected.to be_an_instance_of(RSpec::Hive::Connector) }
  end

  describe '.configure' do
    let(:expected_host) { '127.0.0.1' }
    let(:expected_port) { '10000' }
    let(:expected_host_shared_directory_path) do
      '/Users/Shared/tmp/spec-files'
    end
    let(:expected_docker_shared_directory_path) { '/tmp/spec-tmp-files' }

    context 'when file name is provided' do
      let(:file_name) { 'test.yaml' }
      let(:configuration_mock) do
        double(
          described_class::Configuration,
          host: expected_host,
          port: expected_port,
          host_shared_directory_path: expected_host_shared_directory_path,
          docker_shared_directory_path: expected_docker_shared_directory_path
        )
      end

      before do
        expect(described_class).to receive(:new_configuration).
          with(file_name) { configuration_mock }
      end

      subject { described_class.configure(file_name) }

      its(:host) { is_expected.to eq(expected_host) }
      its(:port) { is_expected.to eq(expected_port) }
      its(:host_shared_directory_path) do
        is_expected.to eq(expected_host_shared_directory_path)
      end
      its(:docker_shared_directory_path) do
        is_expected.to eq(expected_docker_shared_directory_path)
      end
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
      its(:host_shared_directory_path) do
        is_expected.to eq(expected_host_shared_directory_path)
      end
      its(:docker_shared_directory_path) do
        is_expected.to eq(expected_docker_shared_directory_path)
      end
    end
  end
end
