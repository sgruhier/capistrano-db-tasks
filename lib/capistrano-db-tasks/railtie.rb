module CapistranoDbTasks
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/capistrano-db-tasks.rake'
      end
    end
  end
end
