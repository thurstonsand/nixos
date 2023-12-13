{ pkgs, lib, ... }:

with pkgs;

let
  macvlan-name = "homenet";
  gluetun-ip = "192.168.1.195";
  send-ip = "192.168.1.224";
  send-redis-ip = "192.168.1.225";
  flaresolverr-ip = "192.168.1.230";
  homarr-ip = "192.168.1.231";
  sonarr-ip = "192.168.1.237";
  radarr-ip = "192.168.1.239";
  prowlarr-ip = "192.168.1.241";
  torrent-restarter-ip = "192.168.1.242";
in
{
  imports = [
    (import ./enhanced-container-module.nix macvlan-name)
    ./watchtower.nix
    # (import ./torrent.nix { inherit gluetun-ip torrent-restarter-ip; }) # WIP
    # (import ./arr-apps.nix { inherit flaresolverr-ip prowlarr-ip sonarr-ip radarr-ip; }) # WIP
    (import ./send.nix { inherit send-redis-ip send-ip; })
    (import ./homarr.nix { inherit homarr-ip; })
  ];
  config = {
    # network drives
    fileSystems = {
      "/apps" = {
        device = "192.168.1.68:/mnt/performance/docker";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60m" ];
      };
      "/watch" = {
        device = "192.168.1.68:/mnt/capacity/watch";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60m" ];
      };
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

    virtualisation.oci-containers.backend = "docker";
  };
}
