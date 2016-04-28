require 'spec_helper'

RSpec.describe RSpec::Hive::DbName do
  describe '.random_name' do
    subject { described_class.random_name }

    before do
      allow(described_class).to receive(:timestamp) { 'timestamp' }
      allow(described_class).to receive(:random_key) { 'randomKey' }
    end

    it { is_expected.to eq('timestamp_randomKey') }
  end
end
