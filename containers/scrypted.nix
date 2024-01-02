{ scrypted-ip }:
{
  virtualisation.enhanced-containers = {
    scrypted = {
      image = "koush/scrypted";
      ip = scrypted-ip;
      ports = [ "11080:11080" "10443:10443" ];
      volumes = [
        "/apps/scrypted/server/volume:/server/volume"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        SCRYPTED_INSECURE_PORT = "11080";
        SCRYPTED_SECURE_PORT = "10443";
      };
    };
  };
}
