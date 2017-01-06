module Capistrano
  module DbTasks
    module Database
      class << self
        def check(local_db, remote_db)
          raise 'Remote and local server must have some adapter' unless local_db.adapter.class == remote_db.adapter.class
        end

        def remote_to_local(instance)
          local_db  = Capistrano::DbTasks::Databases::Local.new(instance)
          remote_db = Capistrano::DbTasks::Databases::Remote.new(instance)

          check(local_db, remote_db)

          begin
            remote_db.dump.download
          ensure
            remote_db.clean_dump_if_needed
          end
          local_db.load(remote_db.output_file, instance.fetch(:db_local_clean))
        end

        def local_to_remote(instance)
          local_db  = Capistrano::DbTasks::Databases::Local.new(instance)
          remote_db = Capistrano::DbTasks::Databases::Remote.new(instance)

          check(local_db, remote_db)

          local_db.dump.upload
          remote_db.load(local_db.output_file, instance.fetch(:db_local_clean))
          File.unlink(local_db.output_file) if instance.fetch(:db_local_clean)
        end
      end
    end
  end
end
