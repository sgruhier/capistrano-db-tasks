module Database
  class Base 
    attr_accessor :config
    def initialize(cap_instance)
      @cap = cap_instance
    end
    
    def mysql?
      @config['adapter'] == 'mysql'
    end
    
    def credentials
      " -u #{@config['username']} " + (@config['password'] ? " -p\"#{@config['password']}\" " : '')
    end
    
    def database
      @config['database']
    end
    
  private
    def dump_cmd
      "mysqldump #{credentials} #{database}"
    end

    def import_cmd(file)
      "mysql #{credentials} -D #{database} < #{file}"
    end
  end

  class Remote < Base
    attr_accessor :output_file
    def initialize(cap_instance)
      super(cap_instance)
      @cap.run("cat #{@cap.current_path}/config/database.yml") { |c, s, d| @config = YAML.load(d)[@cap.rails_env.to_s] }
    end
          
    def output_file
      @output_file ||= "db/dump_#{database}.sql.bz2"
    end
    
    def dump
      @cap.run "cd #{@cap.current_path}; #{dump_cmd} | bzip2 - - > #{output_file}"
      self
    end
    
    def download(local_file = "#{output_file}") 
      remote_file = "#{@cap.current_path}/#{output_file}"
      
      server = @cap.find_servers(:roles => :db).first
      @cap.sessions[server].sftp.connect {|tsftp| tsftp.download!(remote_file, local_file) }
    end
  end

  class Local < Base
    def initialize(cap_instance)
      super(cap_instance)
      @config = YAML.load_file(File.join('config', 'database.yml'))[@cap.local_rails_env]
    end
    
    def load(file)
      unzip_file = File.join(File.dirname(file), File.basename(file, '.bz2'))
      system("bunzip2 -f #{file} && rake db:drop db:create && #{import_cmd(unzip_file)} && rake db:migrate") 
    end
  end
  
  def self.check(local_db, remote_db) 
    unless local_db.mysql? && remote_db.mysql?
      raise 'Only mysql on remote and local server is supported' 
    end
  end
end
