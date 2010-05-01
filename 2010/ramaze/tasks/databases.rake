namespace :db do
  task :load_config => :environment do
    Sequel.extension :migration
    Sequel.extension :schema_dumper
    Sequel.extension :pretty_table
    # require 'sequel/extensions/pretty_table'
  end

  task :list_tables => [:load_config] do 
    DB.tables.each_with_index do |table_name, i|
      puts "#{'%3d' % (i+1)}: #{table_name}"
    end
  end

  desc "Displays content of table"
  task :show, [:table] => [:load_config] do |t, args|
    args.table ? DB[args.table.to_sym].print : Rake::Task["db:list_tables"].invoke
  end
  
  desc "Displays schema of table"
  task :desc, [:table] => [:load_config] do |t, args|
    def o(value, size = 25)
      "%#{-1*size}s" % value.to_s
    end
    unless args[:table]
      Rake::Task["db:list_tables"].invoke
    else
      puts '==[' << args.table << ']' << '=' * (80 - args.table.size - 4)
      DB.schema(args.table.to_sym).each_with_index do |col, i|
       name, info = col
       puts "#{o i+1, -3}: #{o name}:#{o info[:type], 15}:#{o info[:db_type], 15}:#{' not null ' unless info[:allow_null]} #{' pk ' if info[:primary_key]} #{' default: ' << info[:default].to_s if info[:default]}"
      end
      puts '-' * 80
      indexes = DB.indexes(args.table.to_sym)
      if indexes.size == 0
        puts "  No indexes defined"
      else
        indexes.each_with_index do |idx, i|
          name, attrs = idx
          puts '  ' << o(name, 28) << ": unique? " << o(attrs[:unique] ? 'yes' : 'no', 6) << ': ' << attrs[:columns].join(', ')
        end
      end
      puts '=' * 80
    end
  end

  namespace :schema do
    desc "drops the schema, using schema.rb"
    task :drop => [:load_config, :dump] do
      eval(File.read(File.join(RAMAZE_ROOT, 'db', 'schema.rb'))).apply(DB, :down)
    end
    
    desc "loads the schema from db/schema.rb"
    task :load => :load_config do
      eval(File.read(File.join(RAMAZE_ROOT, 'db', 'schema.rb'))).apply(DB, :up)
      latest_version = Sequel::Migrator.latest_migration_version(File.join(RAMAZE_ROOT, 'db', 'migrate'))
      Sequel::Migrator.set_current_migration_version(DB, latest_version)
      puts "Database schema loaded version #{latest_version}"
    end
    
    desc "Dumps the schema to db/schema.db"
    task :dump => :load_config do
      schema = DB.dump_schema_migration
      schema_file = File.open(File.join(RAMAZE_ROOT, 'db', 'schema.rb'), "w"){|f| f.write(schema)}
    end
    
    desc "Returns current schema version"
    task :version => :load_config do
      puts "Current Schema Version: #{Sequel::Migrator.get_current_migration_version(DB)}"
    end
  end
  
  desc "Migrate the database through scripts in db/migrate and update db/schema.rb by invoking db:schema:dump. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :load_config do
    Sequel::Migrator.apply(DB, File.join(RAMAZE_ROOT, 'db', 'migrate'))
    Rake::Task["db:schema:dump"].invoke
    Rake::Task["db:schema:version"].invoke
  end

  namespace :migrate do
    desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
    task :redo => :load_config do
      Rake::Task["db:rollback"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:schema:dump"].invoke
    end

    desc 'Runs the "up" for a given migration VERSION.'
    task :up => :load_config do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      puts "migrating up to version #{version}"
      Sequel::Migrator.apply(DB, File.join(RAMAZE_ROOT, 'db', 'migrate'), version)
      Rake::Task["db:schema:dump"].invoke 
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down => :load_config do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      current_version = Sequel::Migrator.get_current_migration_version(DB)
      down_version = current_version - step
      down_version = 0 if down_version < 0
      puts "migrating down to version #{down_version}"
      Sequel::Migrator.apply(DB, File.join(RAMAZE_ROOT, 'db', 'migrate'), down_version)
      Rake::Task["db:schema:dump"].invoke
    end
    
    desc "Creates a new migrate script" 
    task :new, [:table, :verb] => :load_config do |t, args|
      unless args[:table]
        puts "need to provide a table name:  rake db:migrate:new[new_table]"
      else
        table = args.table
        verb = args.verb || 'create'
        migrate_path = File.join(RAMAZE_ROOT,'db', 'migrate')
        last_file = File.basename(Dir.glob(File.join(migrate_path, '*.rb')).sort.last)
        next_value = last_file.scan(/\d+/).first.to_i + 1
        filename = '%03d' % next_value << "_" << args.table << '.rb'
        File.open(File.join(migrate_path, filename), 'w') do |file|
          file.puts "class #{verb.capitalize}#{table.capitalize} < Sequel::Migration\n"
          file.puts "\tdef up"
          file.puts "\t\t#{verb}_table :#{table} do"
          file.puts "\t\t\tprimary_key\t:id"
          file.puts "\t\tend"
          file.puts "\tend\n\n"
          file.puts "\tdef down\n"
          file.puts "\t\tdrop_table :#{table}"
          file.puts "\tend"
          file.puts "end"
        end
      end
    end
  end

  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
  task :rollback => :load_config do
    Rake::Task["db:migrate:down"].invoke
  end

  desc 'Drops and recreates the database from db/schema.rb for the current environment.'
  task :reset => ['db:schema:drop', 'db:schema:load']
end
