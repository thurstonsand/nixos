{ gluetun-ip, torrent-restarter-ip }:
{ pkgs, ... }:
let
  qbittorrent-webui-port = "80";
in
{
  virtualisation.enhanced-containers = {
    gluetun = {
      image = "qmcgaw/gluetun";
      ip = gluetun-ip;
      capAdd = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      ports = [
        "8888:8888/tcp" # HTTP proxy
        "8388:8388/tcp" # Shadowsocks
        "8388:8388/udp" # Shadowsocks
        "${qbittorrent-webui-port}:${qbittorrent-webui-port}" # qbittorrent web ui
        "6881:6881" # qbittorrent
        "6881:6881/udp" # qbittorrent
      ];
      volumes = [
        "/apps/torrent/gluetun/gluetun:/gluetun"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        VPN_SERVICE_PROVIDER = "mullvad";
        #VPN_TYPE = "openvpn";
        #OPENVPN_USER = "0667895742885164";
        VPN_TYPE = "wireguard";
        # Driven Wombat
        WIREGUARD_PRIVATE_KEY = "EI4VfvjPW0e1N5CNRb/Z4IM0pia+jOwzhrwz+O57El0=";
        WIREGUARD_ADDRESSES = "10.64.61.38/32";
        SERVER_CITIES = "Atlanta GA";
        FIREWALL_OUTBOUND_SUBNETS = "192.168.1.0/24";
        UPDATER_PERIOD = "24h";
        PUID = "3001";
        PGID = "3001";
      };
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent";
      extraOptions = [
        "--network=container:gluetun"
      ];
      volumes = [
        "/apps/torrent/qbittorrent/config:/config"
        "/watch:/watch"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        WEBUI_PORT = qbittorrent-webui-port;
        PUID = "3001";
        PGID = "3001";
      };
      dependsOn = [ "gluetun" ];
    };

    torrent-restarter = with pkgs; let
      torrent-restarter-script = writeScriptBin "torrent-restarter.sh" ''
        #! /bin/bash

        sleep 10

        echo "monitoring qbittorrent for external access on http://${gluetun-ip}:${qbittorrent-webui-port}"
        while true; do
            if ! curl -s -o /dev/null --fail "http://${gluetun-ip}:${qbittorrent-webui-port}"; then
                date '+%F %T: qbittorrent unreachable; restarting container'
                docker restart qbittorrent
            fi
            sleep 60
        done
      '';
      image-name = "torrent-restarter";
      image-version = "latest";
      torrent-restarter-image = dockerTools.buildLayeredImage {
        name = image-name;
        tag = image-version;
        contents = [ torrent-restarter-script bash docker coreutils curlMinimal ];
        config.Cmd = [ "/bin/torrent-restarter.sh" ];
      };
    in
    {
      image = "${image-name}:${image-version}";
      imageFile = torrent-restarter-image;
      ip = torrent-restarter-ip;
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime:ro"
      ];
      dependsOn = [ "qbittorrent" ];
    };
  };
}
