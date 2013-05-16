if Capistrano::Configuration.instance(false)

  Capistrano::Configuration.instance(true).load do |instance|

    require File.expand_path("#{File.dirname(__FILE__)}/util")
    require File.expand_path("#{File.dirname(__FILE__)}/database")
    require File.expand_path("#{File.dirname(__FILE__)}/asset")

    instance.set :local_rails_env, ENV['RAILS_ENV'] || 'development' unless exists?(:local_rails_env)
    instance.set :rails_env, 'production' unless exists?(:rails_env)
    instance.set :db_local_clean, false unless exists?(:db_local_clean)
    instance.set :assets_dir, 'system' unless exists?(:assets_dir)
    instance.set :local_assets_dir, 'public' unless exists?(:local_assets_dir)
    instance.set :database_yml_path, 'config/database.yml' unless exists?(:database_yml_path)

    namespace :db do
      namespace :remote do
        desc 'Synchronize your remote database using local database data'
        task :sync, :roles => :db do
          local_db = Database::Local.new(instance).database
          remote_db = Database::Remote.new(instance).database
          puts "\n"
          puts "Local database : " + "#{local_db}".blue
          puts "Remote database: " + "#{remote_db}".red
          puts "\n"
          if Util.prompt "Replace remote database?".red
            if Util.sign_with_stage(instance.stage)
              Database.local_to_remote(instance)
            end
          end
        end
      end

      namespace :local do
        desc 'Synchronize your local database using remote database data'
        task :sync, :roles => :db do
          local_db = Database::Local.new(instance).database
          remote_db = Database::Remote.new(instance).database
          puts "\n"
          puts "Remote database: " + "#{remote_db}".red
          puts "Local database : " + "#{local_db}".blue
          puts "\n"
          if Util.prompt "Replace local database?".blue
            Database.remote_to_local(instance)
          end
        end
      end

      desc 'Synchronize your local database using remote database data'
      task :pull do
        db.local.sync
      end

      desc 'Synchronize your remote database using local database data'
      task :push do
        db.remote.sync
      end
    end

    namespace :assets do
      namespace :remote do
        desc 'Synchronize your remote assets using local assets'
        task :sync, :roles => :app do
          puts "\n"
          puts "Asset directories: " + assets_dir.join(', ')
          puts "\n"
          if Util.prompt "Replace remote assets?".red
            if Util.sign_with_stage(instance.stage)
              Asset.local_to_remote(instance)
            end
          end
        end
      end

      namespace :local do
        desc 'Synchronize your local assets using remote assets'
        task :sync, :roles => :app do
          puts "\n"
          puts "Asset directories: " + local_assets_dir.join(', ')
          puts "\n"
          if Util.prompt "Replace local assets?".blue
            Asset.remote_to_local(instance)
          end
        end
      end

      desc 'Synchronize your local assets using remote assets'
      task :pull do
        assets.local.sync
      end

      desc 'Synchronize your remote assets using local assets'
      task :push do
        assets.remote.sync
      end
    end

    namespace :app do
      namespace :remote do
        desc 'Synchronize your remote assets AND database using local assets and database'
        task :sync do
          local_db = Database::Local.new(instance).database
          remote_db = Database::Remote.new(instance).database
          puts "\n"
          puts "Local database   : " + "#{local_db}".blue
          puts "Remote database  : " + "#{remote_db}".red
          puts "Asset directories: " + local_assets_dir.join(', ')
          puts "\n"
          if Util.prompt "Replace remote database AND assets?".red
            if Util.sign_with_stage(instance.stage)
              Database.local_to_remote(instance)
              Asset.local_to_remote(instance)
            end
          end
        end
      end

      namespace :local do
        desc 'Synchronize your local assets AND database using remote assets and database'
        task :sync do
          local_db = Database::Local.new(instance).database
          remote_db = Database::Remote.new(instance).database
          puts "\n"
          puts "Remote database  : " + "#{remote_db}".red
          puts "Local database   : " + "#{local_db}".blue
          puts "Asset directories: " + local_assets_dir.join(', ')
          puts "\n"
          if Util.prompt "Replace local database AND assets?".blue
            Database.remote_to_local(instance)
            Asset.remote_to_local(instance)
          end
        end
      end

      desc 'Synchronize your local assets AND database using remote assets and database'
      task :pull do
        app.local.sync
      end

      desc 'Synchronize your remote assets AND database using local assets and database'
      task :push do
        app.remote.sync
      end

    end
  end

end
