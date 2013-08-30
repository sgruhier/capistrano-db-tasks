module Asset
  extend self

  def remote_to_local(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each_with_index do |dir, index|
      dir = Pathname.new(dir).cleanpath
      local_dir = Pathname.new([cap.local_assets_dir].flatten[index]).cleanpath
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{build_args(cap)} #{cap.user}@#{servers.first}:#{cap.current_path}/#{dir}/ ./#{local_dir}/")
    end
  end

  def local_to_remote(cap)
    servers = cap.find_servers :roles => :app
    port = cap.port rescue 22
    [cap.assets_dir].flatten.each_with_index do |dir, index|
      dir = Pathname.new(dir).cleanpath
      local_dir = Pathname.new([cap.local_assets_dir].flatten[index]).cleanpath
      system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{build_args(cap)} ./#{dir}/ #{cap.user}@#{servers.first}:#{cap.current_path}/#{local_dir}/")
    end
  end

  def to_string(cap)
    [cap.assets_dir].flatten.join(" ")
  end

  def build_args(cap)
    exclusions = [cap.exclude_assets].flatten.map { |pattern| "--exclude #{pattern}" }
    exclusions.concat(cap.rsync_args.flatten).join(" ")
  end

end
