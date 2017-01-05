module Asset
  extend self

  def remote_to_local(cap)
    servers = Capistrano::Configuration.env.send(:servers)
    server = servers.detect { |s| s.roles.include?(:app) }
    port = server.netssh_options[:port] || 22
    user = server.netssh_options[:user] || server.properties.fetch(:user)
    dirs = [cap.fetch(:assets_dir)].flatten
    local_dirs = [cap.fetch(:local_assets_dir)].flatten

    dirs.each_index do |idx|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{user}@#{server}:#{cap.current_path}/#{dirs[idx]} #{local_dirs[idx]}")
    end
  end

  def local_to_remote(cap)
    servers = Capistrano::Configuration.env.send(:servers)
    server = servers.detect { |s| s.roles.include?(:app) }
    port = server.netssh_options[:port] || 22
    user = server.netssh_options[:user] || server.properties.fetch(:user)
    dirs = [cap.fetch(:assets_dir)].flatten
    local_dirs = [cap.fetch(:local_assets_dir)].flatten

    dirs.each_index do |idx|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' ./#{dirs[idx]} #{user}@#{server}:#{cap.current_path}/#{local_dirs[idx]}")
    end
  end

  def to_string(cap)
    [cap.fetch(:assets_dir)].flatten.join(" ")
  end
end
