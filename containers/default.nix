{ pkgs, ... }:

with pkgs;

let
  macvlan-name = "homenet";
  gluetun-ip = "192.168.1.195";
  send-ip = "192.168.1.224";
  send-redis-ip = "192.168.1.225";
  flaresolverr-ip = "192.168.1.230";
  homarr-ip = "192.168.1.231";
  sonarr-ip = "192.168.1.237";
  prowlarr-ip = "192.168.1.241";
  torrent-restarter-ip = "192.168.1.242";
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

  # torrent-restarter-image =
  #   let
  #     cmd = writeScript "torrent-restarter.sh" ''
  #       #! /bin/ash
  #       sleep 10

  #       QBITTORRENT_ADDRESS="192.168.1.195"
  #       QBITTORRENT_PORT=80
  #       echo "monitoring qbittorrent for external access on http://$QBITTORRENT_ADDRESS:$QBITTORRENT_PORT"
  #       while true; do
  #         if ! curl -s -o /dev/null --fail "http://$QBITTORRENT_ADDRESS:$QBITTORRENT_PORT"; then
  #           date '+%F %T: qbittorrent unreachable; restarting container'
  #           docker restart qbittorrent
  #         fi
  #         sleep 60
  #       done
  #     '';
  #   in
  #   dockerTools.buildLayeredImage
  #     {
  #       name = "torrent-restarter";
  #       tag = "latest";
  #       contents = [ curl docker coreutils ];
  #       config = {
  #         Cmd = [ cmd ];
  #       };
  #     };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      watchtower = {
        autoStart = true;
        image = "containrrr/watchtower";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          WATCHTOWER_CLEANUP = "true";
          WATCHTOWER_INCLUDE_RESTARTING = "true";
          WATCHTOWER_SCHEDULE = "30 3 * * *";
        };
      };

      send = {
        autoStart = true;
        image = "registry.gitlab.com/timvisee/send:latest";
        user = "3001:3001";
        extraOptions = [
          "--network=${macvlan-name}"
          "--ip=${send-ip}"
        ];
        ports = [ "80:80" ];
        volumes = [
          "/watch/send/uploads:/uploads"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          BASE_URL = "https://send.thurstons.house";
          PORT = "80";
          MAX_FILE_SIZE = "10737418240"; # 10GB
          DEFAULT_DOWNLOADS = "3";
          MAX_DOWNLOADS = "10";
          FILE_DIR = "/uploads";
          REDIS_HOST = "192.168.1.225";
          CUSTOM_DESCRIPTION = "Encrypt and send files with a link that automatically expires. Made for Thurston to share stuff easily.";
          SEND_FOOTER_CLI_URL = "";
          SEND_FOOTER_SOURCE_URL = "";
        };
        dependsOn = [ "send-redis" ];
      };

      send-redis = {
        autoStart = true;
        image = "redis:alpine";
        user = "3001:3001";
        entrypoint = "redis-server";
        cmd = [ "--appendonly yes" ];
        extraOptions = [
          "--network=${macvlan-name}"
          "--ip=${send-redis-ip}"
        ];
        ports = [ "6379:6379" ];
        volumes = [
          "/apps/send/redis/data:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };

      homarr = {
        autoStart = true;
        image = "ghcr.io/ajnart/homarr:latest";
        user = "3001:3001";
        extraOptions = [
          "--network=${macvlan-name}"
          "--ip=${homarr-ip}"
        ];
        ports = [ "80:80" ];
        volumes = [
          "/apps/homarr/.cache/yarn:/.cache/yarn"
          "/apps/homarr/.yarn:/.yarn"
          "/apps/homarr/app/data/configs:/app/data/configs"
          "/apps/homarr/app/public/icons:/app/public/icons"
          "/apps/homarr/data:/data"
          "/var/run/docker.sock:/var/run/docker.sock"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          PORT = "80";
          NEXTAUTH_URL = "http://865eeb3cd231:7575";
        };
      };

      # gluetun = {
      #   image = "qmcgaw/gluetun";
      #   extraOptions = [
      #     "--network=${macvlan-name}"
      #     "--ip=${gluetun-ip}"
      #     "--cap-add=NET_ADMIN"
      #     "--device=/dev/net/tun:/dev/net/tun"
      #   ];
      #   ports = [
      #     "8888:8888/tcp" # HTTP proxy
      #     "8388:8388/tcp" # Shadowsocks
      #     "8388:8388/udp" # Shadowsocks
      #     "80:80" # qbittorrent web ui
      #     "6881:6881" # qbittorrent
      #     "6881:6881/udp" # qbittorrent
      #   ];
      #   volumes = [
      #     "/apps/torrent/gluetun/gluetun:/gluetun"
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      #   environment = {
      #     VPN_SERVICE_PROVIDER = "mullvad";
      #     #VPN_TYPE = "openvpn";
      #     #OPENVPN_USER = "0667895742885164";
      #     VPN_TYPE = "wireguard";
      #     # Driven Wombat
      #     WIREGUARD_PRIVATE_KEY = "EI4VfvjPW0e1N5CNRb/Z4IM0pia+jOwzhrwz+O57El0=";
      #     WIREGUARD_ADDRESSES = "10.64.61.38/32";
      #     SERVER_CITIES = "Atlanta GA";
      #     FIREWALL_OUTBOUND_SUBNETS = "192.168.1.0/24";
      #     UPDATER_PERIOD = "24h";
      #     PUID = "3001";
      #     PGID = "3001";
      #   };
      # };

      # qbittorrent = {
      #   autoStart = true;
      #   image = "lscr.io/linuxserver/qbittorrent";
      #   extraOptions = [
      #     "--network=container:gluetun"
      #   ];
      #   volumes = [
      #     "/apps/torrent/qbittorrent/config:/config"
      #     "/watch:/watch"
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      #   environment = {
      #     WEBUI_PORT = "80";
      #     PUID = "3001";
      #     PGID = "3001";
      #   };
      #   dependsOn = [ "gluetun" ];
      # };

      # torrent-restarter = {
      #   image = torrent-restarter-image;
      #   extraOptions = [
      #     "--network=${macvlan-name}"
      #     "--ip=${torrent-restarter-ip}"
      #   ];
      #   volumes = [
      #     "/var/run/docker.sock:/var/run/docker.sock"
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      #   dependsOn = [ "qbittorrent" ];
      # };

      # flaresolverr = {
      #   autoStart = true;
      #   image = "ghcr.io/flaresolverr/flaresolverr:latest";
      #   extraOptions = [
      #     "--network=${macvlan-name}"
      #     "--ip=${flaresolverr-ip}"
      #   ];
      #   ports = [ "8191:8191" ];
      #   volumes = [
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      # };

      # prowlarr = {
      #   autoStart = true;
      #   image = "lscr.io/linuxserver/prowlarr:latest";
      #   extraOptions = [
      #     "--network=${macvlan-name}"
      #     "--ip=${prowlarr-ip}"
      #   ];
      #   ports = [ "9696:9696" ];
      #   volumes = [
      #     "/apps/arr-apps/prowlarr/config:/config"
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      #   environment = {
      #     PUID = "3001";
      #     PGID = "3001";
      #   };
      # };

      # sonarr = {
      #   autoStart = true;
      #   image = "linuxserver/sonarr:develop";
      #   extraOptions = [
      #     "--network=${macvlan-name}"
      #     "--ip=${sonarr-ip}"
      #   ];
      #   ports = [ "8989:8989" ];
      #   volumes = [
      #     "/watch:/watch"
      #     "/apps/arr-apps/sonarr/config:/config"
      #     "/etc/localtime:/etc/localtime:ro"
      #   ];
      #   environment = {
      #     PUID = "3001";
      #     PGID = "3001";
      #   };
      # };
    };
  };

}
