module DBHelpers
  def self.generate_db_name
    "#{timestamp}_#{random_key}"
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

  def show_databases(connection)
    connection.fetch('show databases')
  end

  private

  def self.timestamp
    Time.now.getutc.to_i.to_s
  end

  def self.random_key
    SecureRandom.uuid.gsub!('-', '')
  end
end