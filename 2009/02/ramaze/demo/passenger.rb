require 'rubygems'  
require 'ramaze'  

$LOAD_PATH.unshift(__DIR__)  

# Initialize controllers and models  
require 'controller/init'  
require 'model/init'  

Ramaze::Global.sourcereload = false  
Ramaze::Global.sessions = true  
Ramaze::Log.ignored_tags = [:debug, :info]  
