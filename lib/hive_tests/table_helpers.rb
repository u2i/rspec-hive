module TableHelpers
  def load_into_table(table_name, values)
    file = Tempfile.new(Time.now.to_i.to_s, HiveTests.configuration.host_shared_directory_path)
    begin
      values.each do |value|
        file.write(value.join(";"))
        file.write("\n")
      end
      file.flush
      connect do |connection|
        connection.execute("load data local inpath '#{HiveTests.configuration.docked_shared_directory_path}' into table #{table_name}")
      end
    ensure
      file.close
      file.unlink
    end
  end

  def show_tables(connection)
    connection.fetch("SHOW TABLES")
  end
end