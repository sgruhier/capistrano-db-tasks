# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano-db-tasks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'capistrano-db-tasks'
  gem.version     = CapistranoDbTasks::VERSION.dup
  gem.authors     = 'Sébastien Gruhier'
  gem.homepage    = 'https://github.com/sgruhier/capistrano-db-tasks'
  gem.summary     = %q{Add database AND assets tasks to capistrano to a Rails project.}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  
  gem.add_runtime_dependency 'capistrano'
end