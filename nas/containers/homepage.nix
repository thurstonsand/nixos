{ docker-socket-proxy-ip, homepage-ip }:
{
  virtualisation.enhanced-containers = {
    homepage-docker-socket-proxy = {
      image = "ghcr.io/tecnativa/docker-socket-proxy:latest";
      mac-address = "aa:5f:e6:ed:91:31";
      ip = docker-socket-proxy-ip;
      ports = [ "2375:2375" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      environment = {
        CONTAINERS = "1";
        POST = "0";
      };
    };
    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      mac-address = "aa:3d:4a:69:04:ca";
      ip = homepage-ip;
      ports = [ "80:80" ];
      volumes = [
        "/apps/homepage/app/config:/app/config"
        "/apps/homepage/app/public/images:/app/public/images"
        "/etc/localtime:/etc/localtime:ro"

        # for tracking on the page
        "/apps:/apps"
        "/watch:/watch"
      ];
      environment = {
        "PUID" = "3001";
        "PGID" = "3001";
        "PORT" = "80";
      };
    };
  };
}
