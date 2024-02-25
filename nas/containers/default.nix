{ pkgs, lib, ... }:

with pkgs;

let
  macvlan-name = "homenet";
  vlans = import ../vlans.nix;
  zwave-js-ui-ip = "192.168.1.206";
  homarr-ip = "192.168.1.231";
  mosquitto-ip = "192.168.1.232";
  unifi-client-check-ip = "192.168.1.233";

  # external vlan
  cloudflared-ip = "192.168.5.225";
  homeassistant-ip = "192.168.5.226";
  overseerr-ip = "192.168.5.227";

  # personal vlan
  gluetun-ip = "192.168.6.226";
  torrent-restarter-ip = "192.168.6.227";
  flaresolverr-ip = "192.168.6.228";
  prowlarr-ip = "192.168.6.229";
  sonarr-ip = "192.168.6.230";
  radarr-ip = "192.168.6.231";
  scrypted-ip = "192.168.6.232";

  # various secrets that these containers need
  secrets = with builtins; fromJSON (readFile ./secrets.json);
in
{
  imports = [
    ./enhanced-container-module.nix
    ./watchtower.nix
    ./ddclient.nix
    ./isponsorblocktv.nix
    (import ./torrent.nix { inherit gluetun-ip torrent-restarter-ip; secrets = secrets.torrent; })
    (import ./cloudflared.nix { inherit cloudflared-ip; token = secrets.cloudflare-token; })
    (import ./homeassistant.nix { inherit homeassistant-ip; })
    (import ./zwave-js-ui.nix { inherit zwave-js-ui-ip; })
    (import ./scrypted.nix { inherit scrypted-ip; })
    (import ./arr-apps.nix { inherit flaresolverr-ip prowlarr-ip sonarr-ip radarr-ip overseerr-ip; })
    (import ./homarr.nix { inherit homarr-ip; })
    (import ./mosquitto.nix { inherit mosquitto-ip; })
    (import ./unifi-client-check.nix {
      inherit unifi-client-check-ip;
      secrets = secrets.unifi-client-check;
    })

    # no longer using
    # (import ./ntp-server.nix { inherit ntp-server-ip; })
    # (import ./tailscaled.nix { inherit tailscaled-ip; auth-key = secrets.tailscale-auth-key; })
    # (import ./send.nix { inherit send-redis-ip send-ip; })
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
