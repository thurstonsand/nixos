{mosquitto-ip}: {
  virtualisation.enhanced-containers = {
    mosquitto = {
      image = "eclipse-mosquitto:latest";
      user = "3001:3001";
      mac-address = "aa:bc:fa:6a:0d:1f";
      ip = mosquitto-ip;
      ports = [
        "1883:1883"
        "8883:8883"
        "9001:9001"
      ];
      environment = {
        RUN_INSECURE_MQTT_SERVER = "0";
        PUID = "3001";
        PGID = "3001";
      };
      volumes = [
        "/apps/mosquitto/config:/mosquitto/config"
        "/apps/mosquitto/data:/mosquitto/data"
        "/apps/mosquitto/log:/mosquitto/log"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };
  };
}
