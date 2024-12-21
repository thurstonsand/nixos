{homeassistant-ip}: {
  virtualisation.enhanced-containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      mac-address = "aa:7a:ef:16:ff:bf";
      ip = homeassistant-ip;
      ports = ["80:80"];
      volumes = [
        "/apps/homeassistant/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      devices = [
        "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813026A9-if01-port0:/dev/zigbee"
      ];
      # doesn't seem to need this, even tho documentation recommends it
      # extraOptions = [
      #   "--privileged"
      # ];
    };
  };
}
