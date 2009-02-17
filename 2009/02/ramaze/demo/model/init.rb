# Here goes your database connection and options:
require 'activerecord'
require 'cleanup_connection_patch'

ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => "db/demo.sqlite3"
  )

require 'model/post'
