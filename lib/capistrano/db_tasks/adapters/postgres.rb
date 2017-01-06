module Capistrano
  module DbTasks
    module Adapters
      class Postgres < Base
        def self.suitable?(adapter)
          %w(postgresql pg postgis).include? adapter
        end

        def credentials
          credential_params = ""
          username = config['username'] || config['user']

          credential_params << " -U #{username} " if username
          credential_params << " -h #{config['host']} " if config['host']
          credential_params << " -p #{config['port']} " if config['port']

          credential_params
        end

        def dump_cmd
          "#{pgpass} pg_dump #{credentials} #{database} #{dump_cmd_opts}"
        end

        def import_cmd(file)
          terminate_connection_sql = "SELECT pg_terminate_backend(pg_stat_activity.pid) " \
            "FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database}' AND pid <> pg_backend_pid();"

          "#{pgpass} psql -c \"#{terminate_connection_sql};\" #{credentials} #{database};" \
          "#{pgpass} dropdb #{credentials} #{database};" \
          "#{pgpass} createdb #{credentials} #{database};" \
          "#{pgpass} psql #{credentials} -d #{database} < #{file}"
        end

        private

        def pgpass
          config['password'] ? "PGPASSWORD='#{config['password']}'" : ""
        end

        def dump_cmd_opts
          "--no-acl --no-owner #{dump_cmd_ignore_tables_opts} #{dump_cmd_ignore_data_tables_opts}"
        end

        def dump_cmd_ignore_tables_opts
          ignore_tables = @cap.fetch(:db_ignore_tables, [])
          ignore_tables.map { |t| "--exclude-table=#{t}" }.join(" ")
        end

        def dump_cmd_ignore_data_tables_opts
          ignore_tables = @cap.fetch(:db_ignore_data_tables, [])
          ignore_tables.map { |t| "--exclude-table-data=#{t}" }.join(" ")
        end
      end
    end
  end
end
