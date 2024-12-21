{
  cloudflared-ip,
  token,
}: {
  virtualisation.enhanced-containers = {
    cloudflared = {
      image = "cloudflare/cloudflared";
      mac-address = "aa:ac:db:0f:4f:d5";
      ip = cloudflared-ip;
      cmd = ["tunnel" "--no-autoupdate" "run" "--token" token];
    };
  };
}
