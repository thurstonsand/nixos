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
      script-name = "torrent-restarter.sh";
      torrent-restarter-script = writeScriptBin script-name ''
        #! /bin/bash

        echo "monitoring qbittorrent for external access on http://${gluetun-ip}:${qbittorrent-webui-port}"
        sleep 10

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
        contents = [ bash docker coreutils curlMinimal torrent-restarter-script ];
        config.Cmd = [ "/bin/${script-name}" ];
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

    myanonymouse-ddns = with pkgs; let
      # there were some weird SSL issues when going with scratch image,
      # so need to base it on alpine image.
      # there should be a better way to do this: https://github.com/NixOS/nix/issues/7180
      # for now, to get updated values, you need to run the following:
      # nix run nixpkgs.nix-prefetch-docker -c nix-prefetch-docker --image-name alpine --image-tag latest
      alpine-base-image = dockerTools.pullImage {
        imageName = "alpine";
        imageDigest = "sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48";
        sha256 = "0zaaibcjkrgxhp9gf50zp87yax8v2p7a1kqld94z8l62bhq0ilpa";
      };
      script-name = "myanonymouse-update.sh";
      myanonymouse-update-script = writeScriptBin script-name ''
        #!/bin/ash

        echo "starting myanonymouse ddns update script"
        sleep 10

        while true; do
          echo "updating ip being used for anonymouse"
          curl -c /cookies/mam.cookies -b /cookies/mam.cookies https://t.myanonamouse.net/json/dynamicSeedbox.php
          echo $?
          sleep 129600 # 1.5 days
        done
      '';
      image-name = "myanonymouse-ddns";
      image-version = "latest";
      myanonymouse-ddns-image = dockerTools.buildLayeredImage {
        name = image-name;
        tag = image-version;
        fromImage = alpine-base-image;
        contents = [ curl myanonymouse-update-script ];
        config.Cmd = [ "/bin/${script-name}" ];
      };
    in
    {
      image = "${image-name}:${image-version}";
      imageFile = myanonymouse-ddns-image;
      user = "3001:3001";
      extraOptions = [
        "--network=container:gluetun"
      ];
      volumes = [
        "/apps/torrent/myanonymouse-ddns/cookies:/cookies"
      ];
      dependsOn = [ "gluetun" ];
    };
  };
}
