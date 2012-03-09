module Asset
  extend self

  def remote_to_local(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each do |dir|
      system("rsync -a --del --progress --rsh='ssh -p #{port}' #{cap.user}@#{servers.first}:#{cap.shared_path}/#{dir} #{cap.local_assets_dir}")
    end
  end

  def to_string(cap)
    [cap.assets_dir].flatten.join(" ")
  end
end
