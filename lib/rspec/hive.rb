require 'rspec/hive/version'
require 'rspec/hive/db_name'
require 'rspec/hive/configuration'
require 'rspec/hive/connection_delegator'
require 'rspec/hive/connector'
require 'rspec/hive/with_hive_connection'
require 'rspec/hive/query_builder'
require 'rspec/hive/matchers'

module RSpec
  module Hive
    def self.configuration
      @configuration
    end

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
end

require 'rspec/rake_tasks/railtie' if defined?(Rails)
