# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Hive::DbName do
  describe '.random_name' do
    subject { described_class.random_name }

    before do
      allow(described_class).to receive(:timestamp).and_return('timestamp')
      allow(described_class).to receive(:random_key).and_return('randomKey')
    end

    it { is_expected.to eq('timestamp_randomKey') }
  end
end
