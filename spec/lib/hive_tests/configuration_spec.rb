require 'spec_helper'

describe HiveTests::Configuration do
  RSpec.shared_examples('config') do
    its(:host) { is_expected.to eq(expected_host) }
    its(:port) { is_expected.to eq(expected_port) }
    its(:host_shared_directory_path) { is_expected.to eq(expected_host_shared_directory_path) }
    its(:docker_shared_directory_path) { is_expected.to eq(expected_docker_shared_directory_path) }
    its(:hive_version) { is_expected.to eq(expected_hive_version) }
  end

  context 'when no configuration file is provided' do
    let(:expected_host) { '192.168.99.100' }
    let(:expected_port) { '10000' }
    let(:expected_host_shared_directory_path) { '/Users/Shared/tmp/spec-tmp-files' }
    let(:expected_docker_shared_directory_path) { '/tmp/spec-tmp-files' }
    let(:expected_hive_version) { 10 }

    subject { described_class.new }

    include_examples('config')
  end

  context 'when there is a configuration file' do
    let(:yaml_hash) do
      {'hive' =>
         {
           'host' => '127.0.0.2',
           'port' => '10001',
           'host_shared_directory_path' => '/Users/Shared/tmp/spec-tmp-files',
           'docker_shared_directory_path' => '/tmp/spec-tmp-file',
           'hive_version' => '10'
         }
      }
    end
    let(:expected_host) { '127.0.0.2' }
    let(:expected_port) { '10001' }
    let(:expected_host_shared_directory_path) { '/Users/Shared/tmp/spec-tmp-files' }
    let(:expected_docker_shared_directory_path) { '/tmp/spec-tmp-file' }
    let(:expected_hive_version) { 10 }

    before do
      expect(YAML).to receive(:load_file) { yaml_hash }
    end

    subject { described_class.new(yaml_hash) }

    include_examples('config')
  end
end