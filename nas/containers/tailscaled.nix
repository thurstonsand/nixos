{ tailscaled-ip, auth-key }:
{
  virtualisation.enhanced-containers = {
    tailscaled = {
      image = "tailscale/tailscale";
      user = "3001:3001";
      capAdd = [ "NET_ADMIN" "NET_RAW" ];
      ip = tailscaled-ip;
      volumes = [
        "/apps/tailscaled/var/lib:/var/lib"
        "/dev/net/tun:/dev/net/tun"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = "3001";
        PGID = "3001";
        TS_USERSPACE = "true";
        TS_AUTH_KEY = auth-key;
        TS_ROUTES = "192.168.1.0/24";
        TS_STATE_DIR = "/var/lib";
      };
    };
  };
}
