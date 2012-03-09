# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capistrano-db-tasks/version"

Gem::Specification.new do |s|
  s.name        = "capistrano-db-tasks"
  s.version     = CapistranoDbTasks::VERSION
  s.authors     = ["Sebastien Gruhier"]
  s.email       = ["sebastien.gruhier@xilinus.com"]
  s.homepage    = "https://github.com/sgruhier/capistrano-db-tasks"
  s.summary     = %q{TODO}
  s.description = %q{TODO}

  s.rubyforge_project = "capistrano-db-tasks"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "capistrano"
end
