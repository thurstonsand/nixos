{ flaresolverr-ip, prowlarr-ip, sonarr-ip, radarr-ip }:
{
  virtualisation.enhanced-containers = {
    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      ip = flaresolverr-ip;
      ports = [ "8191:8191" ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
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
  };
}
