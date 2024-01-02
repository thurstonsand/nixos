{
  virtualisation.enhanced-containers = {
    ddclient = {
      image = "lscr.io/linuxserver/ddclient:latest";
      environment = {
        PUID = "3001";
        PGID = "3001";
        TZ = "US/Eastern";
      };
      volumes = [
        "/apps/ddclient/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };
  };
}
