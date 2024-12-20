{scrypted-ip}: {
  virtualisation.enhanced-containers = {
    scrypted = {
      image = "koush/scrypted";
      mac-address = "aa:83:cc:9f:fc:1e";
      ip = scrypted-ip;
      ports = ["11080:11080" "10443:10443"];
      volumes = [
        # Avahi Daemon mDNS
        # "/var/run/dbus:/var/run/dbus"
        # "/var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket"

        "/apps/scrypted/server/volume:/server/volume"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        SCRYPTED_INSECURE_PORT = "11080";
        SCRYPTED_SECURE_PORT = "10443";

        SCRYPTED_WEBHOOK_UPDATE_AUTHORIZATION = "Bearer OSQJR0yDKlYijzPy4!sWwNJZ=!BWypoFgPFtVZw5JUEvhy=CSC/k1y=R!huOeJj5!TYaC9oT4BWdvwiEfK";
        SCRYPTED_WEBHOOK_UPDATE = "http://localhost:10444/v1/update";
      };
    };
  };
}
