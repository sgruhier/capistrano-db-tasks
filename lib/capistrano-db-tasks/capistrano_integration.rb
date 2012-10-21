require 'capistrano'
require 'capistrano/version'

module CapistranoDbTasks
  class CapistranoIntegration
    def self.load_into(capistrano_config)
      capistrano_config.load do
        require File.expand_path("#{File.dirname(__FILE__)}/util")
        require File.expand_path("#{File.dirname(__FILE__)}/database")
        require File.expand_path("#{File.dirname(__FILE__)}/asset")
  
        set :local_rails_env, ENV['RAILS_ENV'] || 'development' unless exists?(:local_rails_env)
        set :rails_env, 'production' unless exists?(:rails_env)
        set :stage, 'production' unless exists?(:stage)
        set :db_local_clean, false unless exists?(:db_local_clean)
        set :assets_dir, 'system' unless exists?(:assets_dir)
        set :local_assets_dir, 'public' unless exists?(:local_assets_dir)

        namespace :db do
          namespace :remote do
            desc 'Synchronize the local database to the remote database'
            task :sync, :roles => :db do
              if Util.prompt 'Are you sure you want to REPLACE THE REMOTE DATABASE with local database'
                Database.local_to_remote(self)
              end
            end
          end
    
          namespace :local do
            desc 'Synchronize your local database using remote database data'
            task :sync, :roles => :db do
              puts "Local database: #{Database::Local.new(self).database}"
              if Util.prompt 'Are you sure you want to erase your local database with server database'
                Database.remote_to_local(self)
              end
            end
          end
    
          desc 'Synchronize your local database using remote database data'
          task :pull do 
            db.local.sync
          end
    
          desc 'Synchronize the local database to the remote database'
          task :push do 
            db.remote.sync
          end
        end
  
        namespace :assets do
          namespace :local do
            desc 'Synchronize your local assets using remote assets'
            task :sync, :roles => :app do
              puts "Assets directories: #{Asset.to_string(self)}"
              if Util.prompt "Are you sure you want to erase your local assets with server assets"
                Asset.remote_to_local(self)
              end
            end
          end
    
          desc 'Synchronize your local assets using remote assets'
          task :pull do 
            assets.local.sync
          end
        end
  
        namespace :app do
          namespace :local do
            desc 'Synchronize your local assets AND database using remote assets and database'
            task :sync do
              puts "Local database     : #{Database::Local.new(self).database}"
              puts "Assets directories : #{Asset.to_string(self)}"
              if Util.prompt "Are you sure you want to erase your local database AND your local assets with server database and assets(#{assets_dir})"
                Database.remote_to_local(self)
                Asset.remote_to_local(self)
              end
            end
          end
          desc 'Synchronize your local assets AND database using remote assets and database'
          task :pull do 
            app.local.sync
          end
    
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  CapistranoDbTasks::CapistranoIntegration.load_into(Capistrano::Configuration.instance)
end