require 'rbhive'
require 'tempfile'
require 'yaml'

module HiveTests
  class Connector
    attr_reader :result, :config

    def initialize(configuration)
      @config = configuration
      # transport: :sasl, sasl_params: {username: 'hive', password: ''},
    end

    def start_connection(db_name = HiveTests::DbName.random_name)
      connection = open_connection
      connection.switch_database(db_name)
      @config.hive_options.each do |key, value|
        connection.execute("SET #{key}=#{value};")
      end

      connection

    rescue Thrift::ApplicationException => e
      config.logger.fatal('An exception was thrown during start connection')
      config.logger.fatal(e)
      stop_connection(connection)
      connection
    end

    def stop_connection(connection)
      connection.close_session if connection.session
      connection.close
    rescue IOError => e
      config.logger.fatal('An exception was thrown during close connection')
      config.logger.fatal(e)
    end

    def tlcli_connect
      RBHive.tcli_connect(@config.host,
                          @config.port,
                          connection_options) do |connection|
        yield HiveTests::ConnectionDelegator.new(connection, @config)
      end
    end

    private

    def log_connection_params
      @config.logger.info('Opening connection.')
      @config.logger.info("Connection options: #{connection_options}")
      @config.logger.info("Config #{@config}")
    end

    def open_connection
      log_connection_params

      connection = RBHive::TCLIConnection.new(
        @config.host,
        @config.port,
        connection_options
      )
      connection = HiveTests::ConnectionDelegator.new(connection, @config)

      connection.open
      connection.open_session
      connection
    end

    def connection_options
      {
        hive_version: @config.hive_version,
        transport: :sasl,
        sasl_params: {},
        logger: @config.logger,
        timeout: @config.connection_timeout
      }
    end
  end
end
