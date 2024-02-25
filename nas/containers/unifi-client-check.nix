{ unifi-client-check-ip, secrets }:
{
  virtualisation.enhanced-containers = {
    unifi-client-check = {
      image = "zsamuels28/unificlientalerts:latest";
      mac-address = "aa:3b:95:d2:8a:cb";
      ip = unifi-client-check-ip;
      environment = {
        "UNIFI_CONTROLLER_USER" = "localadmin";
        "UNIFI_CONTROLLER_PASSWORD" = secrets.localadmin-password;
        "UNIFI_CONTROLLER_URL" = "https://192.168.1.1:443";
        "TELEGRAM_BOT_TOKEN" = secrets.telegram-bot-token;
        "TELEGRAM_CHAT_ID" = secrets.telegram-chat-id;
      };
    };
  };
}
