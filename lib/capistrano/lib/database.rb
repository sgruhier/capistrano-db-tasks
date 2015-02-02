module Database
  class Base
    attr_accessor :config, :output_file
    def initialize(cap_instance)
      @cap = cap_instance
    end

    def mysql?
      @config['adapter'] =~ /^mysql/
    end

    def postgresql?
      %w(postgresql pg).include? @config['adapter']
    end

    def credentials
      credential_params = ""
      if mysql?
        username = @config['username'] || @config['user']
        credential_params << " -u #{username} " if username
        credential_params << " -p'#{@config['password']}' " if @config['password']
        credential_params << " -h #{@config['host']} " if @config['host']
        credential_params << " -S #{@config['socket']} " if @config['socket']
        credential_params << " -P #{@config['port']} " if @config['port']
      elsif postgresql?
        credential_params << " -U #{@config['username']} " if @config['username']
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
      @output_file ||= "db/#{database}_#{current_time}.sql.bz2"
    end

    def pgpass
      "PGPASSWORD='#{@config['password']}'" if @config['password']
    end

  private

    def dump_cmd
      if mysql?
        "mysqldump #{credentials} #{database} --lock-tables=false"
      elsif postgresql?
        "#{pgpass} pg_dump --no-acl --no-owner #{credentials} #{database}"
      end
    end

    def import_cmd(file)
      if mysql?
        "mysql #{credentials} -D #{database} < #{file}"
      elsif postgresql?
        terminate_connection_sql = "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database}' AND pid <> pg_backend_pid();"
        "#{pgpass} psql -c \"#{terminate_connection_sql};\" #{credentials}; #{pgpass} dropdb #{credentials} #{database}; #{pgpass} createdb #{credentials} #{database}; #{pgpass} psql #{credentials} -d #{database} < #{file}"
      end
    end

  end

  class Remote < Base
    def initialize(cap_instance)
      super(cap_instance)

      @cap.within @cap.current_path do
        @cap.with rails_env: @cap.fetch(:rails_env) do
          @config = @cap.capture(:rake, 'capistrano_db_tasks:config', '2>/dev/null')
        end
      end
      @config = YAML.load(@config)
    end

    def dump
      @cap.execute "cd #{@cap.current_path} && #{dump_cmd} | bzip2 - - > #{output_file}"
      self
    end

    def download(local_file = "#{output_file}")
      @cap.download! dump_file_path, local_file
    end

    def clean_dump_if_needed
      if @cap.fetch(:db_remote_clean)
        @cap.execute "rm -f #{dump_file_path}"
      else
        @cap.info "leaving #{dump_file_path} on the server (add \"set :db_remote_clean, true\" to deploy.rb to remove)"
      end
    end

    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, '.bz2'))
      # @cap.run "cd #{@cap.current_path} && bunzip2 -f #{file} && RAILS_ENV=#{@cap.rails_env} bundle exec rake db:drop db:create && #{import_cmd(unzip_file)}"
      @cap.execute "cd #{@cap.current_path} && bunzip2 -f #{file} && RAILS_ENV=#{@cap.fetch(:rails_env)} && #{import_cmd(unzip_file)}"
      @cap.execute("cd #{@cap.current_path} && rm #{unzip_file}") if cleanup
    end

    private

    def dump_file_path
      "#{@cap.current_path}/#{output_file}"
    end
  end

  class Local < Base
    def initialize(cap_instance)
      super(cap_instance)
      @config = YAML.load(ERB.new(File.read(File.join('config', 'database.yml'))).result)[fetch(:local_rails_env).to_s]
      puts "local #{@config}"
    end

    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, '.bz2'))
      # system("bunzip2 -f #{file} && bundle exec rake db:drop db:create && #{import_cmd(unzip_file)} && bundle exec rake db:migrate")
      @cap.info "executing local: bunzip2 -f #{file} && #{import_cmd(unzip_file)}"
      system("bunzip2 -f #{file} && #{import_cmd(unzip_file)}")
      if cleanup
        @cap.info "removing #{unzip_file}"
        File.unlink(unzip_file)
      else
        @cap.info "leaving #{unzip_file} (specify :db_local_clean in deploy.rb to remove)"
      end
      @cap.info "Completed database import"
    end

    def dump
      system "#{dump_cmd} | bzip2 - - > #{output_file}"
      self
    end

    def upload
      remote_file = "#{@cap.current_path}/#{output_file}"
      @cap.upload! output_file, remote_file
    end
  end


  class << self
    def check(local_db, remote_db)
      unless (local_db.mysql? && remote_db.mysql?) || (local_db.postgresql? && remote_db.postgresql?)
        raise 'Only mysql or postgresql on remote and local server is supported'
      end
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
