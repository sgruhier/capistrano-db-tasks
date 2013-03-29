module Asset
  extend self

  def remote_to_local(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each_with_index do |dir, index|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{build_exclusions(cap)} #{cap.user}@#{servers.first}:#{cap.current_path}/#{dir} #{[cap.local_assets_dir].flatten[index]}")
    end
  end

  def local_to_remote(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each_with_index do |dir, index|
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{build_exclusions(cap)} ./#{dir} #{cap.user}@#{servers.first}:#{cap.current_path}/#{cap.local_assets_dir}")
    end
  end

  def to_string(cap)
    [cap.assets_dir].flatten.join(" ")
  end

  def build_exclusions(cap)
    [cap.exclude_assets].flatten.map { |pattern| "--exclude #{pattern}" }.join(" ")
  end
end
