require 'capistrano/lib/util'
require 'capistrano/lib/database'
require 'capistrano/lib/asset'

require_relative 'capistrano-db-tasks'

namespace :load do
  task :defaults do
    set :local_rails_env, ENV['RAILS_ENV'] || 'development' unless fetch(:local_rails_env)
    set :rails_env, fetch(:stage) || 'production' unless fetch(:rails_env)
    set :db_local_clean, false unless fetch(:db_local_clean)
    set :assets_dir, 'system' unless fetch(:assets_dir)
    set :local_assets_dir, 'public' unless fetch(:local_assets_dir)
    set :skip_data_sync_confirm, (ENV['SKIP_DATA_SYNC_CONFIRM'].to_s.downcase == 'true')
    set :disallow_pushing, false unless fetch(:disallow_pushing)
  end
end
