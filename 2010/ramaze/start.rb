# Use this file directly like `ruby start.rb` if you don't want to use the
# `ramaze start` command.
# All application related things should go into `app.rb`, this file is simply
# for options related to running the application locally.

require File.join(File.expand_path(File.dirname(__FILE__)), 'app')

Ramaze.start(:adapter => :webrick, :port => 7000, :file => __FILE__)
