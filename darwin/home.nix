let
  username = "thurstonsand";
in {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
  };
  programs = {
    zsh.shellAliases = {
      switch = "darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixos";
    };
  };
}
