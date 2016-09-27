module Asset
  extend self

  def remote_to_local(cap)
    raise "server with role app is undefined" if server.nil?
    # puts "assets_dir: #{cap.shared_path}/#{Array(cap.fetch(:assets_dir))}"
    # puts "local_assets_dir: #{Array(cap.fetch(:local_assets_dir))}"
    Array(cap.fetch(:assets_dir)).each do |dir|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{user}@#{server}:#{cap.shared_path}/#{dir} #{Array(cap.fetch(:local_assets_dir)).join}")
    end
  end

  def local_to_remote(cap)
    raise "server with role app is undefined" if server.nil?
    Array(cap.fetch(:assets_dir)).each do |dir|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' ./#{dir} #{user}@#{server}:#{cap.current_path}/#{Array(cap.fetch(:local_assets_dir)).join}")
    end
  end

  def to_string(cap)
    [cap.fetch(:assets_dir)].flatten.join(" ")
  end

  private

  def server
    servers = Capistrano::Configuration.env.send(:servers)
    servers.detect { |s| s.roles.include?(:app) }
  end

  def port
    server.netssh_options[:port] || 22
  end

  def user
    server.netssh_options[:user]
  end
end
