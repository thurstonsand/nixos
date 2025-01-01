{...}: {
  # home-manager options: https://mipmip.github.io/home-manager-option-search/
  home = {
    username = "thurstonsand";
    homeDirectory = "/home/thurstonsand";
  };

  programs = {
    zsh.shellAliases = {
      switch = "sudo nixos-rebuild switch --flake /home/thurstonsand/nixos";
    };
  };

  systemd.user.startServices = "sd-switch";
}
