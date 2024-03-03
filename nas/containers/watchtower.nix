{ watchtower-ip, secrets }:
{
  virtualisation.enhanced-containers = {
    watchtower = {
      image = "containrrr/watchtower";
      mac-address = "aa:3d:69:30:d7:c8";
      ip = watchtower-ip;
      ports = [ "8080" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        WATCHTOWER_CLEANUP = "true";
        WATCHTOWER_INCLUDE_RESTARTING = "true";
        WATCHTOWER_SCHEDULE = "30 3 * * *";
        WATCHTOWER_HTTP_API_METRICS = "true";
        WATCHTOWER_HTTP_API_TOKEN = secrets.http-api-token;

        # telegram notifications
        WATCHTOWER_NOTIFICATION_URL = "telegram://${secrets.telegram.token}@telegram?chats=${secrets.telegram.chat-id}";
      };
    };
  };
}
