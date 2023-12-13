{ gluetun-ip, torrent-restarter-ip }:

{

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
        "80:80" # qbittorrent web ui
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
        WEBUI_PORT = "80";
        PUID = "3001";
        PGID = "3001";
      };
      dependsOn = [ "gluetun" ];
    };

    # torrent-restarter = {
    #   image = torrent-restarter-image;
    #   ip = torrent-restarter-ip;
    #   volumes = [
    #     "/var/run/docker.sock:/var/run/docker.sock"
    #     "/etc/localtime:/etc/localtime:ro"
    #   ];
    #   dependsOn = [ "qbittorrent" ];
    # };
  };
}
