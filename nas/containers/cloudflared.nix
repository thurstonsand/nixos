{ cloudflared-ip, token }:
{
  virtualisation.enhanced-containers = {
    cloudflared = {
      image = "cloudflare/cloudflared";
      ip = cloudflared-ip;
      cmd = [ "tunnel" "--no-autoupdate" "run" "--token" token ];
    };
  };
}
