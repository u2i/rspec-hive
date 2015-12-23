class Query
  def table_schema
    RBHive::TableSchema.new('people', nil, line_sep: '\n', field_sep: ';') do
      column :name, :string
      column :address, :string
      column :amount, :float
    end
  end

  def table_name
    table_schema.name
  end

  def run_hive_query(connection)
    query = "SELECT * FROM `#{table_schema.name}` WHERE `amount` > 2.5"
    connection.execute(query)
  end
end
