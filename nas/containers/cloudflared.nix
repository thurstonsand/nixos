{ cloudflared-ip }:
let
  token = builtins.readFile ./cloudflared.token;
in
{
  virtualisation.enhanced-containers = {
    cloudflared = {
      image = "cloudflare/cloudflared";
      ip = cloudflared-ip;
      cmd = [ "tunnel" "--no-autoupdate" "run" "--token" token ];
    };
  };
}
