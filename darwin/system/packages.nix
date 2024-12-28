{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    imagemagick
    nil
    # TODO: wait for 1.69 to come out:
    # https://github.com/rclone/rclone/pull/7717
    # rclone
    (symlinkJoin {
      name = "code"; # Name of the resulting package
      paths = []; # Empty because we're not combining existing packages
      postBuild = ''
        mkdir -p $out/bin
        ln -s /opt/homebrew/bin/windsurf $out/bin/code
      '';
    })
  ];
}
