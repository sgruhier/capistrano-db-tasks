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
      if mysql?
        (@config['username'] ? " -u #{@config['username']} " : '') + (@config['password'] ? " -p\"#{@config['password']}\" " : '') + (@config['host'] ? " -h #{@config['host']}" : '') + (@config['socket'] ? " -S#{@config['socket']}" : '')
      elsif postgresql?
        (@config['username'] ? " -U #{@config['username']} " : '') + (@config['host'] ? " -h #{@config['host']}" : '')
      end
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


  private

    def dump_cmd
      if mysql?
        "mysqldump #{credentials} #{database} --lock-tables=false"
      elsif postgresql?
        "pg_dump #{credentials} -c -O #{database}"
      end
    end

    def import_cmd(file)
      if mysql?
        "mysql #{credentials} -D #{database} < #{file}"
      elsif postgresql?
        "psql #{credentials} #{database} < #{file}"
      end
    end

    def create_cmd
      if mysql?
        "mysql #{credentials} --execute \"CREATE DATABASE IF NOT EXISTS #{database};\""
      elsif postgresql?
        # no idea about postgresql
      end
    end

  end

  class Remote < Base
    def initialize(cap_instance)
      super(cap_instance)
      @config = ""
      @cap.run("cat #{@cap.current_path}/#{@cap.database_yml_path}") do |c, s, d|
        @config += d
      end
      @config = YAML.load(@config)[@cap.rails_env.to_s]
    end

    def dump
      @cap.run "cd #{@cap.current_path} && #{dump_cmd} | bzip2 - - > #{output_file}"
      self
    end

    def download(local_file = "#{output_file}")
      remote_file = "#{@cap.current_path}/#{output_file}"
      @cap.get remote_file, local_file
    end

    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, '.bz2'))
      # @cap.run "cd #{@cap.current_path} && bunzip2 -f #{file} && RAILS_ENV=#{@cap.rails_env} bundle exec rake db:drop db:create && #{import_cmd(unzip_file)}"
      @cap.run "#{create_cmd}"
      @cap.run "cd #{@cap.current_path} && bunzip2 -f #{file} && RAILS_ENV=#{@cap.rails_env} && #{import_cmd(unzip_file)}"
      @cap.run("cd #{@cap.current_path} && rm #{unzip_file}") if cleanup
    end
  end

  class Local < Base
    def initialize(cap_instance)
      super(cap_instance)
      @config = YAML.load_file(@cap.database_yml_path)[@cap.local_rails_env.to_s]
    end

    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, '.bz2'))
      system("#{create_cmd}")
      system("bunzip2 -f #{file} && #{import_cmd(unzip_file)}")
      File.unlink(unzip_file) if cleanup
    end

    def dump
      system "#{dump_cmd} | bzip2 - - > #{output_file}"
      self
    end

    def upload
      remote_file = "#{@cap.current_path}/#{output_file}"
      @cap.upload output_file, remote_file
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

      remote_db.dump.download
      local_db.load(remote_db.output_file, instance.fetch(:db_local_clean))
    end

    def local_to_remote(instance)
      local_db  = Database::Local.new(instance)
      remote_db = Database::Remote.new(instance)

      check(local_db, remote_db)

      local_db.dump.upload
      remote_db.load(local_db.output_file, instance.fetch(:db_local_clean))
    end
  end

end
