require 'rbhive'
require 'tempfile'
require 'securerandom'
require 'yaml'

module HiveTests
  class Connector
    attr_reader :result, :config
    attr_accessor :db_name

    def initialize(configuration, db_name = self.class.generate_random_name)
      @db_name = db_name
      @config = configuration
      # transport: :sasl, sasl_params: {username: 'hive', password: ''},
    end

    def start_connection
      connection = RBHive::TCLIConnection.new(@config.host, @config.port, connection_options)
      connection = HiveTests::ConnectionDelegator.new(connection, @config)
      connection.open
      connection.open_session

      connection.create_database(db_name)
      connection.use_database(db_name)
      connection

    rescue Thrift::ApplicationException => e
      stop_connection(connection)
      connection
    end

    def stop_connection(connection)
      connection.close_session if connection.session
      connection.close
    rescue IOError => e
      # noop
    end

    def connection
      RBHive.tcli_connect(@config.host,
                          @config.port,
                          connection_options) do |connection|
        yield connection
      end
    end

    def connect
      connection do |connection|
        begin
          connection.create_database(db_name)
          connection.use_database(db_name)
          yield connection
        ensure
          connection.drop_database(db_name)
        end
      end
    end

    def self.generate_random_name
      "#{timestamp}_#{random_key}"
    end

    private

    def self.timestamp
      Time.now.getutc.to_i.to_s
    end

    def self.random_key
      SecureRandom.uuid.gsub!('-', '')
    end

    def connection_options
      {
        hive_version: @config.hive_version,
        transport: :sasl,
        sasl_params: {},
        logger: @config.logger
      }
    end
  end
end
