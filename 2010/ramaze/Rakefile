# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

begin; require 'rubygems'; rescue LoadError; end

require 'rake/clean'
require 'rake'
require 'rake/testtask'

PROJECT_SPECS = FileList[
  'spec/{controllers,models,lib}/**/*.rb',
]

DEPENDENCIES = {
  'ramaze' => {:version => '>= 2009.07'},
  'sequel' => {:version => '>= 3.2.0'},
  'i18n'   => {:version => '>=0.3.0'},
}

DEVELOPMENT_DEPENDENCIES = {
  'bacon'            => {:version => '>= 1.1.0'},
  'erubis'           => {:version => '>= 2.6.4'},
  'locale'           => {:version => '~> 2.0.4'},
  'rack-test'        => {:version => '>= 0.4.0', :lib => 'rack/test'},
  'sqlite3-ruby'     => {:version => '~> 1.2.5', :lib => 'sqlite3'},
}

Dir['tasks/*.rake'].each{|f| import(f) }

task :default => [:bacon]

CLEAN.include %w[
  **/.*.sw?
  *.gem
  .config
  **/*~
  **/{data.db,cache.yaml}
  *.yaml
  pkg
  rdoc
  ydoc
  *coverage*
]
