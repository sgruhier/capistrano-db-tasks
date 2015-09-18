module Asset
  extend self

  def remote_to_local(cap)
    servers = Capistrano::Configuration.env.send(:servers)
    server = servers.detect { |s| s.roles.include?(:app) }
    port = server.netssh_options[:port] || 22
    user = server.netssh_options[:user]
    cap.fetch(:assets_dir).to_a.flatten.each do |dir|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{user}@#{server}:#{cap.current_path}/#{dir}/ #{dir}")
    end
  end

  def local_to_remote(cap)
    servers = Capistrano::Configuration.env.send(:servers)
    server = servers.detect { |s| s.roles.include?(:app) }
    port = server.netssh_options[:port] || 22
    user = server.netssh_options[:user]
    cap.fetch(:local_assets_dir).to_a.flatten.each do |dir|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' ./#{dir}/ #{user}@#{server}:#{cap.current_path}/#{dir}")
    end
  end

  def to_string(cap)
    cap.fetch(:assets_dir).to_a.flatten.join(" ")
  end
end
