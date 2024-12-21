{pkgs, ...}: let
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
in {
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
  environment.pathsToLink = ["/share/zsh"];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.thurstonsand.openssh.authorizedKeys.keys = [
    # 1Password
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKQqQSrbXUwjOYu7RlpFoW8iJY5tPg1T9sEpOHp0Ctv"
    # iPad Blink App
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAn2NlLBMeegizVbnIlr2UOnUwwLsxavyeH/tAzZdonqUk6rirRpRgtSkBKSSBFYwQVJqRQjmYFTJ/p8UhbjT5c= admin@ipad"
  ];
}
