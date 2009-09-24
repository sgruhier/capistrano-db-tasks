module Asset
  extend self

  def remote_to_local(cap)
    dirs = to_string(cap)
    # Zip system directory
    cap.run "cd #{cap.shared_path}; tar czf assets.tgz #{dirs}"

    # Copy tgz file from remote to local
    cap.get "#{cap.shared_path}/assets.tgz", "assets.tgz"

    # Unzip file
    system("rm -rf #{dirs}; tar xzvf assets.tgz; rm assets.tgz")
  end
  
  def to_string(cap)
    [cap.assets_dir].flatten.join(" ")
  end
end
