module TableHelpers
  def load_into_table(table_name, values)
    file = Tempfile.new(Time.now.to_i.to_s, '/Users/Shared/tmp/spec-tmp-files')
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

  def show_tables(connection)
    connection.fetch("SHOW TABLES")
  end
end