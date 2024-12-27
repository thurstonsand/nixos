let
  username = "thurstonsand";
in {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # Windsurf files
    file = {
      ".codeium/windsurf/memories/global_rules.md" = {
        source = ./dotfiles/global_rules.md;
        force = true;
      };
      "Library/Application Support/Windsurf/User/tasks.json" = {
        source = ./dotfiles/windsurf-tasks.json;
        force = true;
      };
      ".windsurf/scripts/merge-to-main.sh" = {
        source = ./dotfiles/scripts/merge-to-main.sh;
        executable = true;
        force = true;
      };
    };
  };
  programs = {
    zsh.shellAliases = {
      bd = "brew desc";
      switch = "darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixos";
    };
  };
}
