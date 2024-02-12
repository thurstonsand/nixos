let
  vlan-config = { name, id, unique-subnet }: rec {
    vlan-name = "vlan-${name}";
    macvlan-name = "homenet-${vlan-name}";
    vlan-id = id;
    subnet = "192.168.${unique-subnet}.0/24";
    gateway = "192.168.${unique-subnet}.1";
    ip-range = "192.168.${unique-subnet}.224/27";
  };
in
{
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
}
