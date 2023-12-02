{ pkgs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # to generate user password, recommend: sudo mkpasswd -m sha-512 <password>
    mkpasswd

    # for formatting
    nixpkgs-fmt
    rustc
    cargo
  ];
  programs.zsh.enable = true;
  # completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.thurstonsand.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyt+JJ8TG2quiwUZyzTQ9xB6O6XJ2XLijNBd0+lOA0nT5Dqn96mehAWAK0GmQqJROc52xip/r6iO5KpuaOItE1Uegdr8K0Rk8m7KhrAbKEC2X6TzEhCieUoIWOJYj960lByV4v/y53JeZBdPls5cdfieH0DwIpuwol1249YCxV37oiLogFC62dZDOk3cBvFWJnvLZ2vIYMWI9jczYwrjdsal3G06NxekGurPuDXJLmv2g1Mo6rg3p35+XDaCRd9tWjeYT7gP728NfXjmYVgQuLO2KT7aS9OxeOsrdx+ACMCe1R0af94SDlfSmCySGg5U+eBMDuRXzDip9hANFzidSs8B01rWTg/rUlHuPAs1n/UZNTZ6yObhGrtnZLxJJjGdKXTSWsjNzpxLQleCWhKEO+OvT/qwl9bHHT1iqvckYdfoqh2OkG4xGpxxCUi47srJo0WQMj4ahwMiqLlKBywv6OvDfo7ycqXdXp4xLqOUlbQpF0jQBCe3WkhVmWdC18Om8= thurs@KnownQuantity"
  ];

}
