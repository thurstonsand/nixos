{isponsorblocktv-ip}: {
  virtualisation.enhanced-containers = {
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv";
      ip = isponsorblocktv-ip;
      volumes = [
        "/apps/isponsorblocktv/app/data:/app/data"
      ];
    };
  };
}
