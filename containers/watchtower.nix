{
  virtualisation.enhanced-containers = {
    watchtower = {
      image = "containrrr/watchtower";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        WATCHTOWER_CLEANUP = "true";
        WATCHTOWER_INCLUDE_RESTARTING = "true";
        WATCHTOWER_SCHEDULE = "30 3 * * *";
      };
    };
  };
}
