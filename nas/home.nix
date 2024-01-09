{ pkgs, ... }:

{
  # home-manager options: https://mipmip.github.io/home-manager-option-search/
  home = {
    username = "thurstonsand";
    homeDirectory = "/home/thurstonsand";
  };

  programs = { };

  systemd.user.startServices = "sd-switch";
}
