module Capistrano
  module DbTasks
    module Databases
      class Remote < Base
        def initialize(cap_instance)
          super(cap_instance)
        end

        def dump
          @cap.execute "cd #{@cap.current_path} && #{adapter.dump_cmd} | #{compressor.compress('-', db_dump_file_path)}"
          self
        end

        def download(local_file = "#{output_file}")
          @cap.download! db_dump_file_path, local_file
        end

        def clean_dump_if_needed
          if @cap.fetch(:db_remote_clean)
            @cap.execute "rm -f #{db_dump_file_path}"
          else
            puts "leaving #{db_dump_file_path} on the server (add \"set :db_remote_clean, true\" to deploy.rb to remove)"
          end
        end

        def load(file, cleanup)
          unzip_file = File.join(File.dirname(file), File.basename(file, ".#{compressor.file_extension}"))
          @cap.execute "cd #{@cap.current_path} && #{compressor.decompress(file)} && RAILS_ENV=#{@cap.fetch(:rails_env)} && #{import_cmd(unzip_file)}"
          @cap.execute("cd #{@cap.current_path} && rm #{unzip_file}") if cleanup
        end

        private

        def db_dump_file_path
          "#{db_dump_dir}/#{output_file}"
        end

        def db_dump_dir
          @cap.fetch(:db_dump_dir) || "#{@cap.current_path}/db"
        end

        def load_config!
          puts "Loading remote database config"
          @cap.within @cap.current_path do
            @cap.with rails_env: @cap.fetch(:rails_env) do
              dirty_config_content = @cap.capture(:rails, %(runner "#{DBCONFIG_RAILS_CMD}"), '2>/dev/null')
              # Remove all warnings, errors and artefacts produced by bunlder, rails and other useful tools
              config_content = dirty_config_content.match(/#{DBCONFIG_BEGIN_FLAG}(.*?)#{DBCONFIG_END_FLAG}/m)[1]
              @config = YAML.load(config_content).each_with_object({}) { |(k, v), h| h[k.to_s] = v }
            end
          end
        end
      end
    end
  end
end
