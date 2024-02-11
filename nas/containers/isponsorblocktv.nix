{
  virtualisation.enhanced-containers = {
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.0.4";
      volumes = [
        "/apps/isponsorblocktv/app/data:/app/data"
      ];
    };
  };
}
