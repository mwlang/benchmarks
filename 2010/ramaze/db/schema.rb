Class.new(Sequel::Migration) do
  def up
    create_table(:posts) do
      primary_key :id
      String :title, :size=>255
      String :body, :text=>true
      String :author, :size=>255
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:schema_migrations, :ignore_index_errors=>true) do
      String :version, :null=>false, :size=>255
      
      index [:version], :name=>:unique_schema_migrations, :unique=>true
    end
  end
  
  def down
    drop_table(:posts, :schema_migrations)
  end
end
