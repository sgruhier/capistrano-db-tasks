namespace :capistrano_db_tasks do
  task :config => :environment do
    puts ActiveRecord::Base.configurations[Rails.env].to_yaml
  end
end
