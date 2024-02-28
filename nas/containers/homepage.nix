{ homepage-ip }:
{
  virtualisation.enhanced-containers = {
    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ip = homepage-ip;
      ports = [ "80:80" ];
      volumes = [
        "/apps/homepage/app/config:/app/config"
        "/apps/homepage/app/public/images:/app/public/images"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      environment = {
        "PUID" = "3001";
        "PGID" = "3001";
        "PORT" = "80";
      };
    };
  };
}
