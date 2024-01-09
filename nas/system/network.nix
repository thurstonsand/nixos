{
  # Set hostname.
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "interface-name:ve-*" ];
  };
  networking.hostName = "knownapps";
}
