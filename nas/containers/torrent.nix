{ gluetun-ip, torrent-restarter-ip, secrets }:
{ pkgs, ... }:
let
  qbittorrent-webui-port = "80";
in
{
  virtualisation.enhanced-containers = {
    gluetun = {
      image = "qmcgaw/gluetun";
      mac-address = "aa:be:8f:17:f7:f9";
      ip = gluetun-ip;
      capAdd = [ "NET_ADMIN" ];
      ports = [
        "8000:8000/tcp" # gluetun control server
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
      environment =
        let
          openvpn-config = {
            VPN_TYPE = "openvpn";
            OPENVPN_USER = secrets.openvpn-user;
            # hopefully this pins it to a specific ip address?
            SERVER_HOSTNAMES = "us-atl-ovpn-104";
          };
          wireguard-config = {
            VPN_TYPE = "wireguard";
            # Simple Pup
            WIREGUARD_PRIVATE_KEY = secrets.wireguard-private-key;
            WIREGUARD_ADDRESSES = secrets.wireguard-addresses;
            # hopefully this pins it to a specific ip address?
            SERVER_HOSTNAMES = "us-atl-wg-106";
            VPN_ENDPOINT_PORT = "52345";
          };
        in
        openvpn-config // {
          VPN_SERVICE_PROVIDER = "mullvad";
          SERVER_COUNTRIES = "USA";
          SERVER_CITIES = "Atlanta GA";
          FIREWALL_OUTBOUND_SUBNETS = "192.168.1.0/24";
          UPDATER_PERIOD = "24h";
          PUID = "3001";
          PGID = "3001";
        };
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent";
      hostname = false;
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
      mac-address = "aa:d1:b4:94:58:49";
      ip = torrent-restarter-ip;
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime:ro"
      ];
      extraOptions = [
        "--label"
        "com.centurylinklabs.watchtower.enable=false"
      ];
      dependsOn = [ "qbittorrent" ];
    };

    # to manually set this up once:
    # 1. attach to docker container:
    #    docker exec -it bash qbittorrent
    # 2. get ip address
    #    curl http://whatismyip.akamai.com
    # 3. visit this site: https://www.myanonamouse.net/preferences/index.php?view=security
    #    add entry for ip address
    #    navigate back to main screen
    #    "Allow session to set dynamic seedbox IP"
    #    "View IP locked session cookie"
    #    copy mam_id
    # 4. run the following back in docker container, replacing <session_id>:
    #    curl -b 'mam_id=<session_id>' https://t.myanonamouse.net/json/dynamicSeedbox.php
    #    should receive "Success: true" in response
    #
    # myanonymouse-ddns = with pkgs; let
    # there were some weird SSL issues when going with scratch image,
    # so need to base it on alpine image.
    # there should be a better way to do this: https://github.com/NixOS/nix/issues/7180
    # for now, to get updated values, you need to run the following:
    # nix run nixpkgs#nix-prefetch-docker -- -c nix-prefetch-docker --image-name alpine --image-tag latest
    #     alpine-base-image = dockerTools.pullImage {
    #       imageName = "alpine";
    #       imageDigest = "sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48";
    #       sha256 = "0zaaibcjkrgxhp9gf50zp87yax8v2p7a1kqld94z8l62bhq0ilpa";
    #     };
    #     script-name = "myanonymouse-update.sh";
    #     myanonymouse-update-script = writeScriptBin script-name ''
    #       #!/bin/ash

    #       echo "starting myanonymouse ddns update script"
    #       sleep 10

    #       while true; do
    #         echo "updating ip being used for anonymouse"
    #         curl -c /cookies/mam.cookies -b /cookies/mam.cookies https://t.myanonamouse.net/json/dynamicSeedbox.php
    #         echo $?
    #         sleep 129600 # 1.5 days
    #       done
    #     '';
    #     image-name = "myanonymouse-ddns";
    #     image-version = "latest";
    #     myanonymouse-ddns-image = dockerTools.buildLayeredImage {
    #       name = image-name;
    #       tag = image-version;
    #       fromImage = alpine-base-image;
    #       contents = [ curl myanonymouse-update-script ];
    #       config.Cmd = [ "/bin/${script-name}" ];
    #     };
    #   in
    #   {
    #     image = "${image-name}:${image-version}";
    #     imageFile = myanonymouse-ddns-image;
    #     user = "3001:3001";
    #     hostname = false;
    #     extraOptions = [
    #       "--network=container:gluetun"
    #     ];
    #     volumes = [
    #       "/apps/torrent/myanonymouse-ddns/cookies:/cookies"
    #     ];
    #     dependsOn = [ "gluetun" ];
    #   };
  };
}
