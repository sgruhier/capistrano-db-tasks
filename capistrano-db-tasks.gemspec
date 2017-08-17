# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano-db-tasks/version"

Gem::Specification.new do |gem|
  gem.name        = "capistrano-db-tasks"
  gem.version     = CapistranoDbTasks::VERSION
  gem.authors     = ["Sebastien Gruhier"]
  gem.email       = ["sebastien.gruhier@xilinus.com"]
  gem.homepage    = "https://github.com/sgruhier/capistrano-db-tasks"
  gem.summary     = "A collection of capistrano tasks for syncing assets and databases"
  gem.description = "A collection of capistrano tasks for syncing assets and databases"

  gem.rubyforge_project = "capistrano-db-tasks"

  gem.licenses      = ["MIT"]

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "capistrano", ">= 3.0.0"
end
