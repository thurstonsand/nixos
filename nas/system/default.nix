{
  # nixos options: https://search.nixos.org/options?channel=23.05
  imports = [
    ./boot.nix
    ./devices.nix
    ./hardware-configuration.nix
    ./network.nix
    ./packages.nix
    ./users.nix
  ];

  # enable flakes
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
