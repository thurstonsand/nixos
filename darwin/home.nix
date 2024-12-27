let
  username = "thurstonsand";
in {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # Windsurf global rules file
    file.".codeium/windsurf/memories/global_rules.md".source = ./dotfiles/global_rules.md;
  };
  programs = {
    zsh.shellAliases = {
      bd = "brew desc";
      switch = "darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixos";
    };
  };
}
