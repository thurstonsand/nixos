{ lib, pkgs, ... }:
{
  networking = {
    # Set hostname.
    hostName = "knownapps";

    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:ve-*" ];
    };
  };

  systemd.services = with lib;
    let
      vlans = import ../vlans.nix;
      # config that creates systemd service that calls ip link for a given vlan
      create-ip-link = { vlan-name, vlan-id, ... }:
        {
          "${vlan-name}" = {
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = "true";
            };
            wantedBy = [ "default.target" "docker.service" "docker.socket" ];
            preStart = "${pkgs.iproute2}/bin/ip link delete ens3.${vlan-id} || true";
            script = ''
              ${pkgs.iproute2}/bin/ip link add link ens3 name ens3.${vlan-id} type vlan id ${vlan-id} &&\
              ${pkgs.iproute2}/bin/ip link set dev ens3.${vlan-id} up
            '';
          };
        };
      # config that creates a macvlan linked to a given vlan
      create-linked-macvlan = { vlan-name, macvlan-name, vlan-id, subnet, gateway, ip-range, ... }:
        {
          "docker-network-${macvlan-name}" = {
            serviceConfig = {
              Type = "oneshot";
            };
            wantedBy = [ "default.target" ];
            after = [ "docker.service" "docker.socket" "${vlan-name}.service" ];
            script = ''
              ${pkgs.docker}/bin/docker network inspect ${macvlan-name} > /dev/null 2>&1 ||\
              ${pkgs.docker}/bin/docker network create\
                -d macvlan\
                --subnet=${subnet}\
                --gateway=${gateway}\
                --ip-range=${ip-range}\
                -o parent=ens3.${vlan-id}\
                ${macvlan-name}
            '';
          };
        };
    in
    # since default overlaps preexisting macvlan, comment out for now
    create-ip-link vlans.default //
    create-linked-macvlan vlans.default //
    create-ip-link vlans.iot //
    create-linked-macvlan vlans.iot //
    create-ip-link vlans.external //
    create-linked-macvlan vlans.external //
    create-ip-link vlans.personal //
    create-linked-macvlan vlans.personal;
}

