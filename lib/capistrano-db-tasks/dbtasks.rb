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
          puts "Local database: #{local_db}"
          puts "Remote database: #{remote_db}"
          if Util.prompt "Are you sure you want to REPLACE THE REMOTE DATABASE (#{remote_db}) with local database (#{local_db})"
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
          puts "Local database: #{local_db}"
          puts "Remote database: #{remote_db}"
          if Util.prompt "Are you sure you want to erase your local database (#{local_db}) with server database (#{remote_db})"
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
          puts "Assets directories: #{assets_dir}"
          if Util.prompt "Are you sure you want to erase your server assets with local assets"
            if Util.sign_with_stage(instance.stage)
              Asset.local_to_remote(instance)
            end
          end
        end
      end

      namespace :local do
        desc 'Synchronize your local assets using remote assets'
        task :sync, :roles => :app do
          puts "Assets directories: #{local_assets_dir}"
          if Util.prompt "Are you sure you want to erase your local assets with server assets"
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
          if Util.prompt "Are you sure you want to REPLACE THE REMOTE DATABASE AND your remote assets with local database and assets(#{assets_dir})"
            Database.local_to_remote(instance)
            Asset.local_to_remote(instance)
          end
        end
      end

      namespace :local do
        desc 'Synchronize your local assets AND database using remote assets and database'
        task :sync do
          puts "Local database     : #{Database::Local.new(instance).database}"
          puts "Assets directories : #{local_assets_dir}"
          if Util.prompt "Are you sure you want to erase your local database AND your local assets with server database and assets(#{assets_dir})"
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
