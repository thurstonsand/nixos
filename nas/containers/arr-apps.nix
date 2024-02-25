{ flaresolverr-ip, prowlarr-ip, sonarr-ip, radarr-ip, overseerr-ip }:
{
  virtualisation.enhanced-containers = {
    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      mac-address = "aa:aa:ba:eb:4c:fc";
      ip = flaresolverr-ip;
      ports = [ "8191:8191" ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      mac-address = "aa:bb:ba:ba:8f:f1";
      ip = prowlarr-ip;
      ports = [ "9696:9696" ];
      volumes = [
        "/apps/arr-apps/prowlarr/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = "3001";
        PGID = "3001";
      };
    };

    sonarr = {
      image = "linuxserver/sonarr:develop";
      mac-address = "aa:88:44:f4:6a:d3";
      ip = sonarr-ip;
      ports = [ "8989:8989" ];
      volumes = [
        "/watch:/watch"
        "/apps/arr-apps/sonarr/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = "3001";
        PGID = "3001";
      };
    };

    radarr = {
      image = "linuxserver/radarr";
      mac-address = "aa:fc:67:fd:fb:e8";
      ip = radarr-ip;
      ports = [ "7878:7878" ];
      volumes = [
        "/watch:/watch"
        "/apps/arr-apps/radarr/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = "3001";
        PGID = "3001";
      };
    };

    recyclarr = {
      image = "ghcr.io/recyclarr/recyclarr";
      user = "3001:3001";
      volumes = [
        "/apps/arr-apps/recyclarr/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    overseerr = {
      image = "lscr.io/linuxserver/overseerr:latest";
      mac-address = "aa:06:ca:89:9e:df";
      ip = overseerr-ip;
      ports = [ "80:5055" ];
      volumes = [
        "/apps/arr-apps/overseerr/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = "3001";
        PGID = "3001";
      };
    };
  };
}
