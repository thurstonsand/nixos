let
  username = "thurstonsand";
in {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # Windsurf files
    file = {
      ".codeium/windsurf/memories/global_rules.md" = {
        source = ./dotfiles/.codeium/windsurf/memories/global_rules.md;
        force = true;
      };
      "Library/Application Support/Windsurf/User" = {
        source = ./dotfiles/Library/${"Application Support"}/Windsurf/User;
        recursive = true;
        force = true;
      };
    };
  };
  xdg.configFile."." = {
    source = ./dotfiles/.config;
    recursive = true;
    force = true;
  };

  programs = {
    zsh.shellAliases = {
      bd = "brew desc";
      bh = "brew home";
      switch = "darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixos";
    };
  };
}
