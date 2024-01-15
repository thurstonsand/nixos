{ pkgs, lib, ... }:

with pkgs;

let
  macvlan-name = "homenet";
  tailscaled-ip = "192.168.1.102";
  gluetun-ip = "192.168.1.195";
  cloudflared-ip = "192.168.1.202";
  homeassistant-ip = "192.168.1.205";
  zwave-js-ui-ip = "192.168.1.206";
  scrypted-ip = "192.168.1.210";
  send-ip = "192.168.1.224";
  send-redis-ip = "192.168.1.225";
  overseerr-ip = "192.168.1.228";
  flaresolverr-ip = "192.168.1.230";
  homarr-ip = "192.168.1.231";
  mosquitto-ip = "192.168.1.232";
  sonarr-ip = "192.168.1.237";
  radarr-ip = "192.168.1.239";
  prowlarr-ip = "192.168.1.241";
  torrent-restarter-ip = "192.168.1.242";
in
{
  imports = [
    (import ./enhanced-container-module.nix macvlan-name)
    ./watchtower.nix
    ./ddclient.nix
    ./isponsorblocktv.nix
    (import ./tailscaled.nix { inherit tailscaled-ip; })
    (import ./torrent.nix { inherit gluetun-ip torrent-restarter-ip; })
    (import ./cloudflared.nix { inherit cloudflared-ip; })
    (import ./homeassistant.nix { inherit homeassistant-ip; })
    (import ./zwave-js-ui.nix { inherit zwave-js-ui-ip; })
    (import ./scrypted.nix { inherit scrypted-ip; })
    (import ./arr-apps.nix { inherit flaresolverr-ip prowlarr-ip sonarr-ip radarr-ip overseerr-ip; })
    (import ./send.nix { inherit send-redis-ip send-ip; })
    (import ./homarr.nix { inherit homarr-ip; })
    (import ./mosquitto.nix { inherit mosquitto-ip; })
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
