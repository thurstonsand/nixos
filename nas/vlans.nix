let
  vlan-config = {
    name,
    id,
    unique-subnet,
  }: rec {
    vlan-name = "vlan-${name}";
    macvlan-name = "homenet-${vlan-name}";
    vlan-id = id;
    inherit unique-subnet;
    subnet = "192.168.${unique-subnet}.0/24";
    gateway = "192.168.${unique-subnet}.1";
    ip-range = "192.168.${unique-subnet}.224/27";
  };
in rec {
  default = vlan-config {
    name = "default";
    id = "1";
    unique-subnet = "1";
  };
  iot = vlan-config {
    name = "iot";
    id = "2";
    unique-subnet = "3";
  };
  external = vlan-config {
    name = "external";
    id = "3";
    unique-subnet = "5";
  };
  personal = vlan-config {
    name = "personal";
    id = "4";
    unique-subnet = "6";
  };
  lookup-by-ipv4 = ip: let
    octets = builtins.split "\\." ip;
    # split fn includes the "capture" in the array, so skip over those
    unique-subnet = builtins.elemAt octets 4;
  in
    # temporarily do this before switching over completely
    if unique-subnet == default.unique-subnet
    then default
    else if unique-subnet == iot.unique-subnet
    then iot
    else if unique-subnet == external.unique-subnet
    then external
    else if unique-subnet == personal.unique-subnet
    then personal
    else throw "unexpected ipv4 address: ${ip}; using ${unique-subnet}";
}
