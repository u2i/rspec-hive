require 'hive_tests/configuration'
require 'hive_tests/connector'
require 'hive_tests/db_helpers'
require 'hive_tests/query'
require 'hive_tests/table_helpers'
require 'hive_tests/version'
require 'hive_tests/with_hive_connection'

module HiveTests
  def self.configure(file_name=nil)
    @configuration = Configuration.new(file_name) if file_name
    yield(configuration) if block_given?
    configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.connector
    Connector.new(configuration)
  end
end