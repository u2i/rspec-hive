require 'spec_helper'

describe DockerHelper do
  shared_examples 'without docker' do
    before do
      expect(described_class).to receive(:docker_installed?) { false }
      allow(described_class).to receive(:puts)

      expect(RakeConfig).not_to receive(:default_config_file_path)
      expect(described_class).not_to receive(:load_config_file)
      expect(described_class).not_to receive(:run_docker_using_config)
    end

    it { described_class.run_docker }
  end

  describe '::run_docker' do
    context 'when docker is installed' do
      let(:path) { 'path' }
      let(:hive_config) { {'hive' => 'config'} }

      before do
        expect(described_class).to receive(:docker_installed?) { true }
        expect(RakeConfig).to receive(:default_config_file_path) { path }
        expect(described_class).to receive(:load_config_file).with(path) { hive_config }
        expect(described_class).to receive(:run_docker_using_config).with(hive_config)
      end

      it { described_class.run_docker }
    end

    context 'when no docker' do
      it_behaves_like 'without docker'
    end
  end

  describe '::download_image' do
    context 'when docker is installed' do
      let(:image_name) { 'name' }
      let(:hive_config) { {'hive' => 'config'} }
      let(:cmd) { "docker pull #{image_name}" }
      before do
        expect(described_class).to receive(:docker_installed?) { true }
        expect(RakeConfig).to receive(:default_docker_image_name) { image_name }
        expect(described_class).to receive(:system).with(cmd)
        allow(described_class).to receive(:puts)
      end

      it { described_class.download_image }
    end

    context 'when no docker' do
      it_behaves_like 'without docker'
    end
  end

  describe '::run_docker_using_config' do
    let(:config_mock) { double('config') }
    let(:image_name) { 'name' }
    let(:host_path) { 'host_path' }
    let(:docker_path) { 'docker_path' }
    let(:port) { '1' }

    let(:cmd) { "docker run -v #{:host_path}:#{docker_path} -d -p #{port}:10000 #{image_name}" }

    before do
      expect(RakeConfig).to receive(:default_docker_image_name) { image_name }
      allow(described_class).to receive(:puts)
      expect(described_class).to receive(:system).with(cmd)
      expect(config_mock).to receive(:[]).with('host_shared_directory_path') { host_path }
      expect(config_mock).to receive(:[]).with('docker_shared_directory_path') { docker_path }
      expect(config_mock).to receive(:[]).with('port') { port }
    end

    it { described_class.run_docker_using_config(config_mock) }
  end

  describe '::load_config_file' do
    let(:file_path) { 'path' }

    context 'when config file exist' do
      let(:file_content) do
        <<ERB_FILE
hive:
  key:
    <%= 5+5 %>
ERB_FILE
      end

      let(:result_hash) { {'key' => 10} }

      before do
        expect(File).to receive(:exist?).with(file_path) { true }
        expect(File).to receive(:read).with(file_path) { file_content }
        allow(described_class).to receive(:puts)
      end

      it 'interpolates file using erb' do
        expect(described_class.load_config_file(file_path)).to eq(result_hash)
      end
    end

    context 'when there is no config file' do
      before do
        expect(File).to receive(:exist?).with(file_path) { false }
        allow(described_class).to receive(:puts)
      end

      it 'returns nil' do
        expect(described_class.load_config_file(file_path)).to be_nil
      end
    end
  end
end
