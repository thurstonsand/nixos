{ config, pkgs, ... }:

{
  # nixos options: https://search.nixos.org/options?channel=23.05
  imports = [
    ./hardware-configuration.nix
    ./docker.nix
  ];

  # enable flakes
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Set hostname.
  networking.networkmanager.enable = true;
  networking.hostName = "knownapps";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.displayManager = {
    # Enable the GNOME Desktop Environment.
    gdm.enable = true;

    # Enable automatic login for thurstonsand.
    autoLogin.enable = true;
    autoLogin.user = "thurstonsand";
  };
  services.xserver.desktopManager.gnome.enable = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Disable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    mkpasswd
    wget
    nixpkgs-fmt
    rustc
    cargo
    home-manager
    zsh
  ];
  programs.zsh.enable = true;
  # completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  users.mutableUsers = false;
  users.groups.thurstonsand.gid = 3001;
  users.users.thurstonsand = {
    isNormalUser = true;
    uid = 3001;
    description = "Thurston Sandberg";
    extraGroups = [ "networkmanager" "wheel" "thurstonsand" "docker" ];
    hashedPassword = "$6$AE0TvM4C/X7d3oox$5MO927Q3WXLjFqJTioFJa3nDwzykG6bPwQ4fmVzf2cjXLxuImEbxbrDnK94DHkSCjOwodTv3ohwnT6XBgWoIJ1";
    shell = pkgs.zsh;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.thurstonsand.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyt+JJ8TG2quiwUZyzTQ9xB6O6XJ2XLijNBd0+lOA0nT5Dqn96mehAWAK0GmQqJROc52xip/r6iO5KpuaOItE1Uegdr8K0Rk8m7KhrAbKEC2X6TzEhCieUoIWOJYj960lByV4v/y53JeZBdPls5cdfieH0DwIpuwol1249YCxV37oiLogFC62dZDOk3cBvFWJnvLZ2vIYMWI9jczYwrjdsal3G06NxekGurPuDXJLmv2g1Mo6rg3p35+XDaCRd9tWjeYT7gP728NfXjmYVgQuLO2KT7aS9OxeOsrdx+ACMCe1R0af94SDlfSmCySGg5U+eBMDuRXzDip9hANFzidSs8B01rWTg/rUlHuPAs1n/UZNTZ6yObhGrtnZLxJJjGdKXTSWsjNzpxLQleCWhKEO+OvT/qwl9bHHT1iqvckYdfoqh2OkG4xGpxxCUi47srJo0WQMj4ahwMiqLlKBywv6OvDfo7ycqXdXp4xLqOUlbQpF0jQBCe3WkhVmWdC18Om8= thurs@KnownQuantity"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
