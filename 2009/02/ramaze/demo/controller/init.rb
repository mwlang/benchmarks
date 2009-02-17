# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout '../application'
  engine :Erubis
end

# Here go your requires for subclasses of Controller:
#require 'controller/main'
require 'controller/posts'
