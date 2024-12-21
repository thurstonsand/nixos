{pkgs, ...}: {
  users.mutableUsers = false;
  users.groups.thurstonsand.gid = 3001;
  users.users.thurstonsand = {
    isNormalUser = true;
    uid = 3001;
    description = "Thurston Sandberg";
    extraGroups = ["wheel" "thurstonsand" "docker"];
    hashedPassword = "$6$AE0TvM4C/X7d3oox$5MO927Q3WXLjFqJTioFJa3nDwzykG6bPwQ4fmVzf2cjXLxuImEbxbrDnK94DHkSCjOwodTv3ohwnT6XBgWoIJ1";
    shell = pkgs.zsh;
  };
}
