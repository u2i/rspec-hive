require 'spec_helper'

describe ConfigGeneratorHelper do
  describe '::generate_config' do
    let(:config_mock) { double('config_mock') }
    let(:rake_config) { double('rake_config') }

    before do
      allow(HiveTests::Configuration).to receive(:new) { config_mock }
      expect(RakeConfig).to receive(:load_config) { rake_config }
      expect(described_class).to receive(:create_host_shared_directory).with(rake_config)
      expect(described_class).to receive(:save_to_file).with(rake_config)
    end

    it { described_class.generate_config }
  end

  describe '::save_to_file' do
    let(:file_path) { 'path' }
    let(:config) { double('config mock') }
    let(:config_file_hash) { {'file_path' => file_path} }
    let(:access) { 'w+' }
    let(:file_mock) { double('file_mock') }
    let(:hive_config) { 'hive' }
    let(:yaml_config_mock) { double('yaml') }

    before do
      expect(File).to receive(:open).with(file_path, access).and_yield(file_mock)
      expect(file_mock).to receive(:write).with(yaml_config_mock)
      expect(config).to receive(:[]).with('config_file') { config_file_hash }
      expect(config).to receive(:[]).with('hive') { hive_config }
      expect(hive_config).to receive(:to_yaml) { yaml_config_mock }
      expect(file_mock).to receive(:path) { file_path }
      allow(described_class).to receive(:puts)
    end

    it { described_class.save_to_file(config) }
  end

  describe '::create_host_shared_directory' do
    let(:host_path) { 'path' }
    let(:config_mock) { {'hive' => {'host_shared_directory_path' => host_path}} }

    before do
      expect(described_class).to receive(:system).with('mkdir', '-p', host_path)
    end

    it { described_class.create_host_shared_directory(config_mock) }
  end
end
