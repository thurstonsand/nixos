{ ntp-server-ip }:
{
  virtualisation.enhanced-containers = {
    ntp-server = {
      image = "simonrupf/chronyd";
      ip = ntp-server-ip;
      ports = [
        "123:123/udp"
      ];
    };
  };
}
