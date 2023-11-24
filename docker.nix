{ config, pkgs, ... }:

{
  # network drives
  fileSystems."/apps" = {
    device = "192.168.1.68:/mnt/performance/docker";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60m" ];
  };

  fileSystems."/watch" = {
    device = "192.168.1.68:/mnt/capacity/watch";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60m" ];
  };

  # docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # containers continue to run even if docker daemon crashes/restarts
    liveRestore = true;
    # periodically prune docker resources
    autoPrune.enable = true;
  };


}
