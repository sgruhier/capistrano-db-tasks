module Database
  class Base
    DBCONFIG_BEGIN_FLAG = "__CAPISTRANODB_CONFIG_BEGIN_FLAG__".freeze
    DBCONFIG_END_FLAG = "__CAPISTRANODB_CONFIG_END_FLAG__".freeze

    attr_accessor :config, :output_file

    def initialize(cap_instance)
      @cap = cap_instance
    end

    def mysql?
      @config['adapter'] =~ /^mysql/
    end

    def postgresql?
      %w(postgresql pg postgis).include? @config['adapter']
    end

    def credentials(options = {superuser: false})
      credential_params = ""
      username = (options[:superuser] && @cap.fetch("db_#{options[:location]}_superuser".to_sym)) || @config['username'] || @config['user']
      password = (options[:superuser] && @cap.fetch("db_#{options[:location]}_superuser_password".to_sym)) || @config['password']

      if mysql?
        credential_params << " -u #{username} " if username
        credential_params << " -p'#{password}' " if password
        credential_params << " -h #{@config['host']} " if @config['host']
        credential_params << " -S #{@config['socket']} " if @config['socket']
        credential_params << " -P #{@config['port']} " if @config['port']
      elsif postgresql?
        credential_params << " -U #{username} " if username
        credential_params << " -h #{@config['host']} " if @config['host']
        credential_params << " -p #{@config['port']} " if @config['port']
      end

      credential_params
    end

    def database
      @config['database']
    end

    def current_time
      Time.now.strftime("%Y-%m-%d-%H%M%S")
    end

    def output_file
      @output_file ||= "#{database}_#{current_time}.sql.#{compressor.file_extension}"
    end

    def compressor
      @compressor ||= begin
        compressor_klass = @cap.fetch(:compressor).to_s.split('_').collect(&:capitalize).join
        klass = Object.module_eval("::Compressors::#{compressor_klass}", __FILE__, __LINE__)
        klass
      end
    end

    private

    def pgpass(options = {superuser: false})
      password = (options[:superuser] && @cap.fetch("db_#{options[:location]}_superuser_password".to_sym)) || @config['password']
      password ? "PGPASSWORD='#{password}'" : ""
    end

    def dump_cmd
      if mysql?
        "mysqldump #{credentials} #{database} #{dump_cmd_opts}"
      elsif postgresql?
        "#{pgpass} pg_dump #{credentials} #{database} #{dump_cmd_opts}"
      end
    end

    def import_cmd(file, location = :remote)
      if mysql?
        "mysql #{credentials} -D #{database} < #{file}"
      elsif postgresql?
        owner = @config['username'] || @config['user']
        pg_password = pgpass(superuser: true, location: location)
        pg_credentials = credentials(superuser: true, location: location)
        terminate_connection_sql = "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database}' AND pid <> pg_backend_pid();"
        "#{pg_password} psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{database}; #{pg_password} dropdb #{pg_credentials} #{database}; #{pg_password} createdb #{pg_credentials} --owner=#{owner} #{database}; #{pgpass} psql #{credentials} -d #{database} < #{file}"
      end
    end

    def dump_cmd_opts
      if mysql?
        "--lock-tables=false #{dump_cmd_ignore_tables_opts} #{dump_cmd_ignore_data_tables_opts}"
      elsif postgresql?
        "--no-acl --no-owner #{dump_cmd_ignore_tables_opts} #{dump_cmd_ignore_data_tables_opts}"
      end
    end

    def dump_cmd_ignore_tables_opts
      ignore_tables = @cap.fetch(:db_ignore_tables, [])
      if mysql?
        ignore_tables.map { |t| "--ignore-table=#{database}.#{t}" }.join(" ")
      elsif postgresql?
        ignore_tables.map { |t| "--exclude-table=#{t}" }.join(" ")
      end
    end

    def dump_cmd_ignore_data_tables_opts
      ignore_tables = @cap.fetch(:db_ignore_data_tables, [])
      ignore_tables.map { |t| "--exclude-table-data=#{t}" }.join(" ") if postgresql?
    end
  end

  class Remote < Base
    def initialize(cap_instance)
      super(cap_instance)
      puts "Loading remote database config"
      @cap.within @cap.current_path do
        @cap.with rails_env: @cap.fetch(:rails_env) do
          config_content = @cap.capture(:cat, "config/database.yml")
          @config = YAML.load(config_content)[@cap.fetch(:rails_env).to_s].each_with_object({}) { |(k, v), h| h[k.to_s] = v }
        end
      end
    end

    def dump
      @cap.execute "cd #{@cap.current_path} && #{dump_cmd} | #{compressor.compress('-', db_dump_file_path)}"
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

    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, ".#{compressor.file_extension}"))
      # @cap.run "cd #{@cap.current_path} && bunzip2 -f #{file} && RAILS_ENV=#{@cap.rails_env} bundle exec rake db:drop db:create && #{import_cmd(unzip_file)}"
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
  end

  class Local < Base
    def initialize(cap_instance)
      super(cap_instance)
      puts "Loading local database config"
      dir_with_escaped_spaces = Dir.pwd.gsub ' ', '\ '
      command = "cat config/database.yml"
      config_content, status = Open3.capture2(command)
      raise "Error running command (status=#{status}): #{command}" if status != 0

      local_env = ENV['RAILS_ENV'] || 'development'
      @config = YAML.load(config_content)[local_env].each_with_object({}) { |(k, v), h| h[k.to_s] = v }
    end

    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, ".#{compressor.file_extension}"))
      puts "executing local: #{compressor.decompress(file)} && #{import_cmd(unzip_file)}"
      execute("#{compressor.decompress(file)} && #{import_cmd(unzip_file)}")
      if cleanup
        puts "removing #{unzip_file}"
        File.unlink(unzip_file)
      else
        puts "leaving #{unzip_file} (specify :db_local_clean in deploy.rb to remove)"
      end
      puts "Completed database import"
    end

    def dump
      execute "#{dump_cmd} | #{compressor.compress('-', output_file)}"
      self
    end

    def upload
      remote_file = "#{@cap.current_path}/#{output_file}"
      @cap.upload! output_file, remote_file
    end

    private

    def execute(cmd)
      result = system cmd
      @cap.error "Failed to execute the local command: #{cmd}" unless result
      result
    end
  end

  class << self
    def check(local_db, remote_db)
      raise 'Only mysql or postgresql on remote and local server is supported' unless (local_db.mysql? && remote_db.mysql?) || (local_db.postgresql? && remote_db.postgresql?)
    end

    def remote_to_local(instance)
      local_db  = Database::Local.new(instance)
      remote_db = Database::Remote.new(instance)

      check(local_db, remote_db)

      begin
        remote_db.dump.download
      ensure
        remote_db.clean_dump_if_needed
      end
      local_db.load(remote_db.output_file, instance.fetch(:db_local_clean))
    end

    def local_to_remote(instance)
      local_db  = Database::Local.new(instance)
      remote_db = Database::Remote.new(instance)

      check(local_db, remote_db)

      local_db.dump.upload
      remote_db.load(local_db.output_file, instance.fetch(:db_local_clean))
      File.unlink(local_db.output_file) if instance.fetch(:db_local_clean)
    end
  end
end
