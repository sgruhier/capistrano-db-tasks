module Capistrano
  module DbTasks
    module Databases
      class Local < Base
        def initialize(cap_instance)
          super(cap_instance)
        end

        def dump
          run_locally "#{adapter.dump_cmd} | #{compressor.compress('-', output_file)}"
          self
        end

        # cleanup = true removes the mysqldump file after loading, false leaves it in db/
        def load(file, cleanup)
          unzip_file = File.join(File.dirname(file), File.basename(file, ".#{compressor.file_extension}"))
          puts "executing local: #{compressor.decompress(file)} && #{adapter.import_cmd(unzip_file)}"

          run_locally("#{compressor.decompress(file)} && #{adapter.import_cmd(unzip_file)}")

          if cleanup
            puts "removing #{unzip_file}"
            File.unlink(unzip_file)
          else
            puts "leaving #{unzip_file} (specify :db_local_clean in deploy.rb to remove)"
          end
          puts "Completed database import"
        end

        def upload
          remote_file = "#{@cap.current_path}/#{output_file}"
          @cap.upload! output_file, remote_file
        end

        private

        def load_config!
          puts "Loading local database config"

          command = %(#{Dir.pwd}/bin/rails runner "#{DBCONFIG_RAILS_CMD}")
          stdout = run_locally(command)

          config_content = stdout.match(/#{DBCONFIG_BEGIN_FLAG}(.*?)#{DBCONFIG_END_FLAG}/m)[1]
          config = YAML.load(config_content).each_with_object({}) { |(k, v), h| h[k.to_s] = v }

          @config = config
        end
      end
    end
  end
end
