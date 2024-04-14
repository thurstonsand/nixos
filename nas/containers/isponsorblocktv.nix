{
  virtualisation.enhanced-containers = {
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv";
      volumes = [
        "/apps/isponsorblocktv/app/data:/app/data"
      ];
    };
  };
}
