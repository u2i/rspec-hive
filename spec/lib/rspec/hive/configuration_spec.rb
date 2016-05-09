require 'spec_helper'
require 'tempfile'

RSpec.describe RSpec::Hive::Configuration do
  RSpec.shared_examples('config') do
    its(:host) do
      is_expected.to eq(expected_host)
    end

    its(:port) do
      is_expected.to eq(expected_port)
    end

    its(:host_shared_directory_path) do
      is_expected.to match(expected_host_shared_directory_path)
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

    its(:hive_options) do
      is_expected.to eq(expected_hive_options)
    end
  end

  let(:expected_host_shared_directory_path) do
    '/Users/Shared/tmp/spec-tmp-files'
  end
  let(:expected_docker_shared_directory_path) { '/tmp/spec-tmp-files' }
  let(:expected_hive_version) { 10 }
  let(:expected_timeout) { 1800 }
  let(:expected_partition_flag) { 'true' }
  let(:expected_partition_mode) { 'nonstrict' }
  let(:expected_partiton_pernodexi) { '100000' }
  let(:expected_partitions) { '100000' }
  let(:expected_java_opts) { '-Xmx2048m' }
  let(:expected_hive_options) do
    {'hive.exec.dynamic.partition' => expected_partition_flag,
     'hive.exec.dynamic.partition.mode' => expected_partition_mode,
     'hive.exec.max.dynamic.partitions.pernodexi' => expected_partiton_pernodexi,
     'hive.exec.max.dynamic.partitions' => expected_partitions,
     'mapred.child.java.opts' => expected_java_opts}
  end

  context 'when no configuration file is provided' do
    let(:expected_port) { 10000 }
    let!(:original_host_os) { RbConfig::CONFIG['host_os'] }

    before { allow(Dir).to receive(:mktmpdir) { mock_tmpdir } }

    context 'when on Mac' do
      let(:mock_tmpdir) { '/Users/Shared/test/' }
      let(:expected_host) { '192.168.99.100' }
      let(:expected_host_shared_directory_path) { '/Users/Shared/test/spec-tmp-files' }

      before do
        RbConfig::CONFIG['host_os'] = 'mac os'
      end

      after { RbConfig::CONFIG['host_os'] = original_host_os }

      include_examples('config')
    end

    context 'when on Linux' do
      let(:mock_tmpdir) { '/tmp/test/' }
      let(:expected_host) { '127.0.0.1' }
      let(:expected_host_shared_directory_path) { '/tmp/test/spec-tmp-files' }

      before do
        RbConfig::CONFIG['host_os'] = 'linux'
      end

      after { RbConfig::CONFIG['host_os'] = original_host_os }

      include_examples('config')
    end
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

    context 'where there are some parameters required and optional' do
      let(:yaml_hash) do
        {
          'hive' =>
            {
              'host' => '127.0.0.2',
              'port' => 10001,
              'host_shared_directory_path' => expected_host_shared_directory_path,
              'docker_shared_directory_path' => expected_docker_shared_directory_path,
              'hive_version' => 11,
              'timeout' => 60,
              'hive_options' => {
                'mapred.child.java.opts' => '-Xmx64m'
              }
            }
        }
      end
      let(:expected_timeout) { 60 }
      let(:expected_hive_version) { 11 }
      let(:expected_java_opts) { '-Xmx64m' }

      after { File.unlink(path_to_config_file) }

      subject { described_class.new(path_to_config_file) }

      include_examples('config')
    end
  end
end
