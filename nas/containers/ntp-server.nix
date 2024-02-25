{ ntp-server-ip }:
{
  virtualisation.enhanced-containers = {
    ntp-server = {
      image = "simonrupf/chronyd";
      mac-address = "aa:ac:20:1a:e2:22";
      ip = ntp-server-ip;
      ports = [
        "123:123/udp"
      ];
    };
  };
}
