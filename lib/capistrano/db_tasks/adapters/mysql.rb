module Capistrano
  module DbTasks
    module Adapters
      class Mysql < Base
        def self.suitable?(adapter)
          adapter.index('mysql') == 0
        end

        def credentials
          credential_params = ""
          username = config['username'] || config['user']

          credential_params << " -u #{username} " if username
          credential_params << " -p'#{config['password']}' " if config['password']
          credential_params << " -h #{config['host']} " if config['host']
          credential_params << " -S #{config['socket']} " if config['socket']
          credential_params << " -P #{config['port']} " if config['port']

          credential_params
        end

        def dump_cmd
          "mysqldump #{credentials} #{database} #{dump_cmd_opts}"
        end

        def import_cmd(file)
          "mysql #{credentials} -D #{database} < #{file}"
        end

        private

        def dump_cmd_opts
          "--lock-tables=false #{dump_cmd_ignore_tables_opts} #{dump_cmd_ignore_data_tables_opts}"
        end

        def dump_cmd_ignore_tables_opts
          ignore_tables = @cap.fetch(:db_ignore_tables, [])
          ignore_tables.map { |t| "--ignore-table=#{database}.#{t}" }.join(" ")
        end
      end
    end
  end
end
