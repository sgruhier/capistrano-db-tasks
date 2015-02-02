namespace :capistrano_db_tasks do
  task :config => :environment do
    puts Rails.application.config.database_configuration[Rails.env].to_yaml
  end
end
