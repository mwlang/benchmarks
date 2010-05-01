require 'rubygems'
require 'ramaze'

Ramaze.setup :verbose => Ramaze.options.mode == :dev do
  gem 'sequel', :version => '>=3.1.0'
  gem 'erubis', :version => '>=2.6.5'
end

# Load the library files 
Dir[File.join(__DIR__, 'lib', '*.rb')].each{|lib_file| require lib_file}

# Make sure that Ramaze knows where the good stuff is
Ramaze.options.roots = [__DIR__]
Ramaze.options.views = File.join('app', 'views')
Ramaze.options.layouts = File.join(Ramaze.options.views, 'layouts')

# Establish database connection 
DB_CONFIG = YAML.load(File.read(File.join(__DIR__, 'database.yml')))
DB = Sequel.connect(DB_CONFIG[Ramaze.options[:mode].to_s])

# Initialize controllers and models
require __DIR__('app/models/init')
require __DIR__('app/controllers/init')
