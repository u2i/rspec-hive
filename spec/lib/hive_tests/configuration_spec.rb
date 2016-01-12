require 'spec_helper'
require 'tempfile'

describe HiveTests::Configuration do
  RSpec.shared_examples('config') do
    its(:host) do
      is_expected.to eq(expected_host)
    end

    its(:port) do
      is_expected.to eq(expected_port)
    end

    its(:host_shared_directory_path) do
      is_expected.to eq(expected_host_shared_directory_path)
    end

    its(:docker_shared_directory_path) do
      is_expected.to eq(expected_docker_shared_directory_path)
    end

    its(:hive_version) do
      is_expected.to eq(expected_hive_version)
    end

    its(:connection_timeout) do
      is_expected.to eq(expected_timeout)
    end
  end

  let(:expected_host_shared_directory_path) do
    '/Users/Shared/tmp/spec-tmp-files'
  end
  let(:expected_docker_shared_directory_path) { '/tmp/spec-tmp-files' }
  let(:expected_hive_version) { 10 }
  let(:expected_timeout) { 1800 }

  context 'when no configuration file is provided' do
    let(:expected_host) { '192.168.99.100' }
    let(:expected_port) { 10000 }
    let(:mock_tmpdir) { '/tmp' }

    before { allow(Dir).to receive(:tmpdir).and_return(mock_tmpdir) }

    subject { described_class.new }

    include_examples('config')
  end

  context 'when there is a configuration file' do
    let(:path_to_config_file) do
      Tempfile.open(%w(config .yml)) do |f|
        f.write yaml_hash.to_yaml
        f.path
      end
    end
    let(:expected_host) { '127.0.0.2' }
    let(:expected_port) { 10001 }

    context 'where all parameters are present' do
      let(:yaml_hash) do
        {
          'hive' =>
            {
              'host' => '127.0.0.2',
              'port' => 10001,
              'host_shared_directory_path' => expected_host_shared_directory_path,
              'docker_shared_directory_path' => expected_docker_shared_directory_path,
              'hive_version' => '10',
              'timeout' => 1800
            }
        }
      end

      after { File.unlink(path_to_config_file) }

      subject { described_class.new(path_to_config_file) }

      include_examples('config')
    end

    context 'where there are only required parameters' do
      let(:yaml_hash) do
        {
          'hive' =>
            {
              'host' => '127.0.0.2',
              'port' => 10001,
              'host_shared_directory_path' => expected_host_shared_directory_path,
              'docker_shared_directory_path' => expected_docker_shared_directory_path
            }
        }
      end
      let(:expected_hive_version) { 10 }

      after { File.unlink(path_to_config_file) }

      subject { described_class.new(path_to_config_file) }

      include_examples('config')
    end
  end
end
