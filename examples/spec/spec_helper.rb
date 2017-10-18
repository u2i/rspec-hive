# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  require 'rspec/hive'

  RSpec::Hive.configure(File.join(__dir__, '../../rspec-hive.yml'))

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.pattern = '*_spec.rb'

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
