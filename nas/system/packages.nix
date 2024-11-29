{ pkgs, ... }:
let
  container-updater = pkgs.writeScriptBin "container-updater" ''
    #!/${pkgs.bash}/bin/bash
    CONTAINER_NAME="$1"
    IMAGE_NAME="$2"

    CURRENT_IMAGE_ID=$(${pkgs.docker}/bin/docker inspect --format='{{.Image}}' "$CONTAINER_NAME")

    ${pkgs.docker}/bin/docker pull "$IMAGE_NAME"

    NEW_IMAGE_ID=$(${pkgs.docker}/bin/docker inspect --format='{{.Id}}' "$IMAGE_NAME")
    echo "Current image is $CURRENT_IMAGE_ID"
    echo "New Image is $NEW_IMAGE_ID"
    if [[ "$CURRENT_IMAGE_ID" != "$NEW_IMAGE_ID" ]]; then
        echo "Updating $CONTAINER_NAME container to $NEW_IMAGE_ID"
        ${pkgs.docker}/bin/docker rm -f $CONTAINER_NAME
        sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /home/thurstonsand/nixos
    fi
  '';
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    container-updater
    git
    # to generate user password, recommend: sudo mkpasswd -m sha-512 <password>
    mkpasswd
    # TODO: enhance container-updater to send results
    tg
  ];
  # limit journald log size
  services.journald = {
    storage = "persistent";
    extraConfig = ''
      SystemMaxUse=100M
    '';
  };
  programs.zsh.enable = true;
  # completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.thurstonsand.openssh.authorizedKeys.keys = [
    # Windows Desktop
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyt+JJ8TG2quiwUZyzTQ9xB6O6XJ2XLijNBd0+lOA0nT5Dqn96mehAWAK0GmQqJROc52xip/r6iO5KpuaOItE1Uegdr8K0Rk8m7KhrAbKEC2X6TzEhCieUoIWOJYj960lByV4v/y53JeZBdPls5cdfieH0DwIpuwol1249YCxV37oiLogFC62dZDOk3cBvFWJnvLZ2vIYMWI9jczYwrjdsal3G06NxekGurPuDXJLmv2g1Mo6rg3p35+XDaCRd9tWjeYT7gP728NfXjmYVgQuLO2KT7aS9OxeOsrdx+ACMCe1R0af94SDlfSmCySGg5U+eBMDuRXzDip9hANFzidSs8B01rWTg/rUlHuPAs1n/UZNTZ6yObhGrtnZLxJJjGdKXTSWsjNzpxLQleCWhKEO+OvT/qwl9bHHT1iqvckYdfoqh2OkG4xGpxxCUi47srJo0WQMj4ahwMiqLlKBywv6OvDfo7ycqXdXp4xLqOUlbQpF0jQBCe3WkhVmWdC18Om8= thurs@KnownQuantity"
    # iPad Blink App
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAn2NlLBMeegizVbnIlr2UOnUwwLsxavyeH/tAzZdonqUk6rirRpRgtSkBKSSBFYwQVJqRQjmYFTJ/p8UhbjT5c= admin@ipad"
    # Personal MBP M4
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOf7xTths10s+HRlPM11LLAcmwdqS3SaKYOmTMerUITegqAwE66JlWUqjicVnyvC/t7VNj5Zey2CqSM+1FUVyPo= nix"
  ];

}
