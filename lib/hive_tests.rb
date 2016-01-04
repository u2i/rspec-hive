require 'hive_tests/version'
require 'hive_tests/db_name'
require 'hive_tests/configuration'
require 'hive_tests/connection_delegator'
require 'hive_tests/connector'
require 'hive_tests/with_hive_connection'

module HiveTests
  attr_reader :configuration

  def self.configure(file_name = nil)
    @configuration = new_configuration(file_name)
    yield(@configuration) if block_given?
    @configuration
  end

  def self.connector
    @configuration ||= Configuration.new
    Connector.new(@configuration)
  end

  def self.new_configuration(file_name)
    Configuration.new(file_name)
  end

  private_class_method :new_configuration
end

require 'rake_tasks/railtie' if defined?(Rails)
