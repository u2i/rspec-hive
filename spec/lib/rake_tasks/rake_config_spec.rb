require 'spec_helper'

describe RakeConfig do
  describe '::default_docker_image_name' do
    let(:expected_name) { 'nielsensocial/hive' }
    it do
      expect(described_class.default_docker_image_name).to eq(expected_name)
    end
  end

  describe '::load_config' do
    let(:config_mock) { double('config') }
    let(:hive_config_mock) { 'hive' }
    let(:config_file_mock) { 'file' }
    let(:docker_mock) { 'docker' }

    let(:config) do
      {'hive' => hive_config_mock,
       'config_file' => config_file_mock,
       'docker' => docker_mock}
    end

    before do
      expect(described_class).to receive(:load_hive_config) { hive_config_mock }
      expect(described_class).to receive(:load_config_file_config) { config_file_mock }
      expect(described_class).to receive(:load_docker_config) { docker_mock }
    end

    it { expect(described_class.load_config(config_mock)).to eq(config) }
  end

  describe '::load_hive_config' do
    let(:configuration) { double('configuration mock') }
    let(:expected_host) { 'host' }
    let(:expected_port) { 'port' }
    let(:expected_host_shared_directory_path) { 'host_shared_directory_path' }
    let(:expected_docker_shared_directory_path) { 'docker_shared_directory_path' }
    let(:expected_hive_version) { 'hive_version' }

    let(:expected_hash) do
      {'host' => 'host',
       'port' => 'port',
       'host_shared_directory_path' => 'host_shared_directory_path',
       'docker_shared_directory_path' => 'docker_shared_directory_path',
       'hive_version' => 'hive_version'}
    end

    context 'when no envs' do
      before do
        expect(configuration).to receive(:host) { expected_host }
        expect(configuration).to receive(:port) { expected_port }
        expect(configuration).to receive(:host_shared_directory_path) { expected_host_shared_directory_path }
        expect(configuration).to receive(:docker_shared_directory_path) { expected_docker_shared_directory_path }
        expect(configuration).to receive(:hive_version) { expected_hive_version }
      end

      it do
        expect(described_class.load_hive_config(configuration)).to eq(expected_hash)
      end
    end

    context 'when envs' do
      before do
        allow(ENV).to receive(:[]).with('HOST') { expected_host }
        allow(ENV).to receive(:[]).with('PORT') { expected_port }
        allow(ENV).to receive(:[]).with('HOST_SHARED_DIR') { expected_host_shared_directory_path }
        allow(ENV).to receive(:[]).with('DOCKER_SHARED_DIR') { expected_docker_shared_directory_path }
        allow(ENV).to receive(:[]).with('HIVE_VERSION') { expected_hive_version }
      end

      it do
        expect(described_class.load_hive_config(configuration)).to eq(expected_hash)
      end
    end

    context 'when some are from env and some from config' do
      before do
        expect(configuration).to receive(:host) { expected_host }
        expect(configuration).to receive(:port) { expected_port }
        expect(configuration).to receive(:host_shared_directory_path) { expected_host_shared_directory_path }

        allow(ENV).to receive(:[]).with('HOST') { nil }
        allow(ENV).to receive(:[]).with('PORT') { nil }
        allow(ENV).to receive(:[]).with('HOST_SHARED_DIR') { nil }
        expect(ENV).to receive(:[]).with('DOCKER_SHARED_DIR') { expected_docker_shared_directory_path }
        expect(ENV).to receive(:[]).with('HIVE_VERSION') { expected_hive_version }
      end

      it do
        expect(described_class.load_hive_config(configuration)).to eq(expected_hash)
      end
    end
  end

  describe '::load_config_file_config' do
    let(:expected_path) { 'path' }
    let(:expected_hash) { {'file_path' => expected_path} }

    context 'when no envs' do
      before do
        expect(ENV).to receive(:[]).with('CONFIG_FILE_PATH') { nil }
        expect(described_class).to receive(:default_config_file_path) { expected_path }
      end

      it do
        expect(described_class.load_config_file_config).to eq(expected_hash)
      end
    end

    context 'when envs' do
      before do
        expect(ENV).to receive(:[]).with('CONFIG_FILE_PATH') { expected_path }
      end

      it do
        expect(described_class.load_config_file_config).to eq(expected_hash)
      end
    end
  end

  describe '::load_docker_config' do
    let(:expected_image_name) { 'docker_name' }
    let(:expected_hash) { {'image_name' => expected_image_name} }

    context 'when no envs' do
      before do
        expect(ENV).to receive(:[]).with('DOCKER_IMAGE_NAME') { nil }
        expect(described_class).to receive(:default_docker_image_name) { expected_image_name }
      end

      it do
        expect(described_class.load_docker_config).to eq(expected_hash)
      end
    end

    context 'when envs' do
      before do
        expect(ENV).to receive(:[]).with('DOCKER_IMAGE_NAME') { expected_image_name }
      end

      it do
        expect(described_class.load_docker_config).to eq(expected_hash)
      end
    end
  end

  describe '::default_config_file_path' do
    let(:file_name) { 'hive_tests_config.yml' }
    let(:basedir) { '.' }

    context 'when no rails' do
      before do
        expect(File).to receive(:join).with(basedir, file_name)
      end

      it do
        described_class.default_config_file_path
      end
    end

    context 'when rails is defined' do
      let(:rails_config_dir) { 'config' }

      before do
        stub_const('Rails', nil)
        expect(File).to receive(:join).with(basedir, rails_config_dir, file_name)
      end

      it do
        described_class.default_config_file_path
      end
    end
  end
end
