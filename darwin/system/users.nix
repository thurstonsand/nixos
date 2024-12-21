let
  hostname = "Thurstons-MacBook-Pro";
  username = "thurstonsand";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  users.users.${username} = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];
}
