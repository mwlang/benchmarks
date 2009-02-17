require 'rubygems'
require 'ramaze'

# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'controller/init'
require 'model/init'

#Ramaze::Global.sourcereload = false
#Ramaze::Global.sessions = false
#Ramaze::Log.ignored_tags = [:debug, :info]

Ramaze.start :adapter => :webrick, :port => 7000
