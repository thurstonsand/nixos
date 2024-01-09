{ homarr-ip }:
{
  virtualisation.enhanced-containers = {
    homarr = {
      image = "ghcr.io/ajnart/homarr:latest";
      user = "3001:3001";
      ip = homarr-ip;
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
        # NEXTAUTH_URL = "http://865eeb3cd231:7575";
      };
    };
  };
}
