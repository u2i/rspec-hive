require 'rbhive'
require 'tempfile'
require 'securerandom'

class Connector
  attr_reader :result
  attr_accessor :db_name

  def initialize(db_name = self.class.generate_db_name)
    @db_name = db_name
    # transport: :sasl, sasl_params: {username: 'hive', password: ''},
  end

  def show_databases
    connect do |connection|
      connection.fetch('show databases');
    end
  end

  def load_into_table(table_name, values)
    file = Tempfile.new(Time.now.to_i.to_s, '/tmp')
    begin
      values.each do |value|
        file.write(value.join(";"))
        file.write("\n")
      end
      file.flush
      connect do |connection|
        connection.execute("load data local inpath '#{file.path}' into table #{table_name}")
      end
    ensure
      file.close
      file.unlink
    end
  end

  def select_from_table
    connect do |connection|
      connection.fetch("SELECT * FROM #{table.name}")
    end
  end

  def create_table
    connect do |connection|
      connection.create_table(table)
    end
  end

  def show_tables(connection)
    connection.fetch("SHOW TABLES")
  end

  def connection
    RBHive.tcli_connect(config[:host],
                        config[:port],
                        connection_options) do |connection|
      yield connection
    end
  end

  def start_connection
    connection = RBHive::TCLIConnection.new(config[:host], config[:port], connection_options)
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

  def connect
    connection do |connection|
      # begin
      create_database(connection, db_name)
      use_database(connection, db_name)
      yield connection
      #ensure
      #  drop_database(connection, db_name)
      #end
    end
  end

  def self.generate_db_name
    "#{timestamp}_#{random_key}"
  end

  def config
    {host: '127.0.0.1', port: 10_000}
    #@config ||= YAML.load_file(File.join('config.yml'))['hive']
  end

  class << self
    private

    def timestamp
      Time.now.getutc.to_i.to_s
    end

    def random_key
      SecureRandom.uuid.gsub!('-', '')
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

  def create_database(connection, name)
    connection.execute("CREATE DATABASE IF NOT EXISTS `#{name}`")
  end

  def use_database(connection, name)
    connection.execute("USE `#{name}`")
  end

  def drop_database(connection, name)
    connection.execute("DROP DATABASE `#{name}`")
  end
end