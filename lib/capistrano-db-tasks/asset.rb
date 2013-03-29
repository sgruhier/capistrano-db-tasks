module Asset
  extend self

  def remote_to_local(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each_with_index do |dir, index|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{cap.user}@#{servers.first}:#{cap.current_path}/#{dir} #{cap.local_assets_dir[index]}")
    end
  end

  def local_to_remote(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each_with_index do |dir, index|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' ./#{dir} #{cap.user}@#{servers.first}:#{cap.current_path}/#{cap.local_assets_dir[index]}")
    end
  end

  def to_string(cap)
    [cap.assets_dir].flatten.join(" ")
  end
end
