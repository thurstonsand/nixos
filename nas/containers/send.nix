{ send-redis-ip, send-ip }: {
  virtualisation.enhanced-containers = {
    send-redis = {
      image = "redis:alpine";
      user = "3001:3001";
      entrypoint = "redis-server";
      cmd = [ "--appendonly yes" ];
      ip = send-redis-ip;
      ports = [ "6379:6379" ];
      volumes = [
        "/apps/send/redis/data:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    send = {
      image = "registry.gitlab.com/timvisee/send:latest";
      user = "3001:3001";
      ip = send-ip;
      ports = [ "80:80" ];
      volumes = [
        "/watch/send/uploads:/uploads"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        BASE_URL = "https://send.thurstons.house";
        PORT = "80";
        MAX_FILE_SIZE = "10737418240"; # 10GB
        DEFAULT_DOWNLOADS = "3";
        MAX_DOWNLOADS = "10";
        FILE_DIR = "/uploads";
        REDIS_HOST = send-redis-ip;
        CUSTOM_DESCRIPTION = "Encrypt and send files with a link that automatically expires. Made for Thurston to share stuff easily.";
        SEND_FOOTER_CLI_URL = "";
        SEND_FOOTER_SOURCE_URL = "";
      };
      dependsOn = [ "send-redis" ];
    };
  };
}
