{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    imagemagick
    nil
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
