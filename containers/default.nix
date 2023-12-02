{ pkgs, ... }:

with pkgs;

let
  macvlan-name = "homenet";
in
{
  # network drives
  fileSystems."/apps" = {
    device = "192.168.1.68:/mnt/performance/docker";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60m" ];
  };

  fileSystems."/watch" = {
    device = "192.168.1.68:/mnt/capacity/watch";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60m" ];
  };

  # docker
  systemd.services."docker-network-macvlan" = {
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "default.target" ];
    after = [ "docker.service" "docker.socket" ];
    script = ''
      ${pkgs.docker}/bin/docker network inspect ${macvlan-name} > /dev/null 2>&1 ||\
      ${pkgs.docker}/bin/docker network create\
        -d macvlan\
        --subnet=192.168.1.68/24\
        --gateway=192.168.1.1\
        -o parent=ens3\
        ${macvlan-name}
    '';
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # containers continue to run even if docker daemon crashes/restarts
    liveRestore = true;
    # periodically prune docker resources
    autoPrune.enable = true;
  };
}
