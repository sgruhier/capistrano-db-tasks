CapistranoDbTasks
=================

Add database AND assets tasks to capistrano to a Rails project.

Currently

* It only supports mysql (both side remote and local)
* Only synchronize remote to local (cap db:local:sync)

Commands mysql, mysqldump, bzip2 and unbzip2 must be in your PATH

Feel free to fork and to add more database support or new tasks.

Install
=======

Add it as a plugin
    ./script/plugin install git://github.com/sgruhier/capistrano-db-tasks.git

Add to config/deploy.rb:
    require 'vendor/plugins/capistrano-db-tasks/lib/dbtasks'
  
    # if you haven't already specified
    set :rails_env, "production"
  
    # if you want to remove the dump file after loading
    set :db_local_clean, true  
    
    # If you want to import assets, you can change default asset dir (default = system)
    # This directory must be in your shared directory on the server
    set :assets_dir, %w(public/assets public/att)
    
    # if you want to work on a specific local environment (default = ENV['RAILS_ENV'] || 'development')
    set :locals_rails_env, "production"
    
Available tasks
===============

* db:local:sync      # Synchronize your local database using remote database data
* assets:local:sync  # Synchronize your local assets using remote assets
* app:local:sync     # Synchronize your local assets AND local database using remote assets and database

Example
=======

cap db:local:sync

or

cap production db:local:sync if you are using capistrano-ext to have multistages

Copyright (c) 2009 [Sébastien Gruhier - XILINUS], released under the MIT license

TODO
====

May be change project's name as it's not only database tasks now :)
Add tests
