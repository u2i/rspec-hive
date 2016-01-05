module HiveTests
  module WithHiveConnection
    def hive
      HiveTests.connector
    end

    def connection
      @connection ||= hive.start_connection
    end

    def self.included(mod)
      mod.before(:all) do
        connection
      end

      mod.before(:each) do
        connection.switch_database(HiveTests::DbName.random_name)
      end

      mod.after(:all) do
        hive.stop_connection(connection) unless hive && connection
      end
    end
  end
end
