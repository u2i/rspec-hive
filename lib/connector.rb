require 'rbhive'
require 'tempfile'
require 'securerandom'
require 'yaml'
require 'db_helpers'
require 'table_helpers'
require 'hive_config'

class Connector
  attr_reader :result
  attr_accessor :db_name

  include DBHelpers
  include TableHelpers

  def initialize(db_name = DBHelpers.generate_db_name)
    @db_name = db_name
    @config = HiveConfig.new(File.join(__dir__, 'docker_config.yml'))
    # transport: :sasl, sasl_params: {username: 'hive', password: ''},
  end

  def start_connection
    connection = RBHive::TCLIConnection.new(@config.host, @config.port, connection_options)
    connection.open
    connection.open_session

    create_database(connection, db_name)
    use_database(connection, db_name)

    connection
  rescue
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
        create_database(connection, db_name)
        use_database(connection, db_name)
        yield connection
      ensure
        drop_database(connection, db_name)
      end
    end
  end

  private

  def connection_options
    {
      hive_version: 10,
      transport: :sasl,
      sasl_params: {},
      logger: Logger.new(STDOUT)
    }
  end
end