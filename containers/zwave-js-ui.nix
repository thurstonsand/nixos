{ zwave-js-ui-ip }:
{
  virtualisation.enhanced-containers = {
    zwave-js-ui = {
      image = "zwavejs/zwave-js-ui:latest";
      ip = zwave-js-ui-ip;
      ports = [ "8091:8091" "3000:3000" ];
      volumes = [
        "/apps/zwave-js-ui/usr/src/app/store:/usr/src/app/store"
        "/etc/localtime:/etc/localtime:ro"
      ];
      devices = [ "/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_813026A9-if00-port0:/dev/zwave" ];
      extraOptions = [
        "--tty"
        "--stop-signal=SIGINT"
      ];
    };
  };
}
