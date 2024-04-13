{ config, lib, ... }:
with lib; with builtins;
let
  vlans = import ../vlans.nix;
  # derived from: https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/virtualisation/oci-containers.nix
  containerOptions = {
    options = {
      image = mkOption {
        type = with types; str;
        description = mdDoc "OCI image to run.";
        example = "library/hello-world";
      };

      imageFile = mkOption {
        type = with types; nullOr package;
        default = null;
        description = mdDoc ''
          Path to an image file to load before running the image. This can
          be used to bypass pulling the image from the registry.

          The `image` attribute must match the name and
          tag of the image contained in this file, as they will be used to
          run the container with that image. If they do not match, the
          image will be pulled from the registry as usual.
        '';
        example = literalExpression "pkgs.dockerTools.buildImage {...};";
      };

      capAdd = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc "capabilities to enable";
        example = literalExpression ''
          ["NET_ADMIN"]
        '';
      };

      entrypoint = mkOption {
        type = with types; nullOr str;
        description = mdDoc "Override the default entrypoint of the image.";
        default = null;
        example = "/bin/my-app";
      };

      cmd = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc "Commandline arguments to pass to the image's entrypoint.";
        example = literalExpression ''
          ["--port=9000"]
        '';
      };

      environment = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = mdDoc "Environment variables to set for this container.";
        example = literalExpression ''
          {
            DATABASE_HOST = "db.example.com";
            DATABASE_PORT = "3306";
          }
        '';
      };

      ip = mkOption {
        type = with types; nullOr str;
        default = null;
        description = mdDoc ''
          IP address to start the container on. If this is set, it will also switch
          to the appropriate macvlan.
        '';
        example = "192.168.6.5";
      };

      hostname = mkOption {
        type = with types; either bool nonEmptyStr;
        default = true;
        description = mdDoc ''
          if hostname is set to true, use the container name for the hostname.
          if hostname is set to false, do not set a hostname.
          if hostname is a string, use that as the hostname.
          default value is to use the container name for hostname.
        '';
        example = "false";
      };

      mac-address = mkOption {
        type = with types; nullOr str;
        default = null;
        description = mdDoc ''
          Mac Address to use for this container. If left unset,
          docker will generate one.
          MUST start with prefix 'aa'.
        '';
        example = "aa:ef:66:74:39:09";
      };

      ports = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc ''
          Network ports to publish from the container to the outer host.

          Valid formats:
          - `<ip>:<hostPort>:<containerPort>`
          - `<ip>::<containerPort>`
          - `<hostPort>:<containerPort>`
          - `<containerPort>`

          Both `hostPort` and `containerPort` can be specified as a range of
          ports.  When specifying ranges for both, the number of container
          ports in the range must match the number of host ports in the
          range.  Example: `1234-1236:1234-1236/tcp`

          When specifying a range for `hostPort` only, the `containerPort`
          must *not* be a range.  In this case, the container port is published
          somewhere within the specified `hostPort` range.
          Example: `1234-1236:1234/tcp`

          Refer to the
          [Docker engine documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) for full details.
        '';
        example = literalExpression ''
          [
            "8080:9000"
          ]
        '';
      };

      user = mkOption {
        type = with types; nullOr str;
        default = null;
        description = mdDoc ''
          Override the username or UID (and optionally groupname or GID) used
          in the container.
        '';
        example = "nobody:nogroup";
      };

      volumes = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc ''
          List of volumes to attach to this container.

          Note that this is a list of `"src:dst"` strings to
          allow for `src` to refer to `/nix/store` paths, which
          would be difficult with an attribute set.  There are
          also a variety of mount options available as a third
          field; please refer to the
          [docker engine documentation](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) for details.
        '';
        example = literalExpression ''
          [
            "volume_name:/path/inside/container"
            "/path/on/host:/path/inside/container"
          ]
        '';
      };

      devices = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc "List of devices to attach to this container.";
        example = literalExpression ''
          [ "/dev/net/tun:/dev/net/tun" ]
        '';
      };

      dependsOn = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc ''
          Define which other containers this one depends on. They will be added to both After and Requires for the unit.

          Use the same name as the attribute under `virtualisation.oci-containers.containers`.
        '';
        example = literalExpression ''
          virtualisation.oci-containers.containers = {
            node1 = {};
            node2 = {
              dependsOn = [ "node1" ];
            }
          }
        '';
      };

      extraOptions = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = mdDoc "Extra options for {command}`docker run`.";
        example = literalExpression ''
          ["--network=host"]
        '';
      };
    };
  };
  cfg = config.virtualisation.enhanced-containers;
in
{
  options.virtualisation.enhanced-containers = mkOption {
    type = with types; attrsOf (submodule containerOptions);
    default = { };
    description = mdDoc "OCI (Docker) containers to run as systemd services.";
  };

  config =
    let
      # same definition as concatMapAttrs, but with recursiveUpdate instead of mergeAttrs
      # potential alternative solution: https://gist.github.com/udf/4d9301bdc02ab38439fd64fbda06ea43
      concatMapAttrsRecursive = f: v:
        foldl' recursiveUpdate { }
          (attrValues
            (mapAttrs f v)
          );
      container-cfg = (container-name:
        opts@{ ip, hostname, mac-address, capAdd, devices, extraOptions, ... }:
        let
          # pull-options = [ "--pull=always" ];
          vlan = vlans.lookup-by-ipv4 ip;
          ip-args = lists.optionals (ip != null) [
            "--network=${vlan.macvlan-name}"
            "--ip=${ip}"
          ];
          hostname-args =
            # if bool is set to true, then use container name
            if ((isBool hostname) && hostname) then [ "--hostname=${container-name}" ]
            # if bool is false, then don't set the value
            else if ((isBool hostname) && !hostname) then [ ]
            # if string is set, use that as the hostname
            else [ "--hostname=${hostname}" ];
          mac-address-args = lists.optional (mac-address != null) "--mac-address=${mac-address}";
          netOptions = ip-args ++ hostname-args ++ mac-address-args;
          capAddOptions = map (cap: "--cap-add=${cap}") capAdd;
          devicesOptions = map (device: "--device=${device}") devices;
          nonEmpty = value: value != null && value != [ ] && value != { };
          addIfExists = opts: attrsets.foldlAttrs (attrs: key: value: attrs // attrsets.optionalAttrs (nonEmpty value) { "${key}" = value; }) { } opts;
        in
        {
          autoStart = true;
          extraOptions = extraOptions ++ netOptions ++ capAddOptions ++ devicesOptions;
        } // addIfExists { inherit (opts) image imageFile entrypoint cmd environment ports user volumes dependsOn; });

      containers-to-autoupdate = filterAttrs (_: { image, ... }: image != null) cfg;
      systemd-cfg = (container-name: { image, ... }:
        let
          update-service-name = "update-${container-name}";
        in
        {
          services."${update-service-name}" = {
            description = "detects when ${container-name} has an update, and then restarts the container to pick up that update";
            script = ''
              container-updater ${container-name} ${image}
            '';
            serviceConfig = {
              Type = "oneshot";
              User = "thurstonsand";
            };
          };
          timers."autoupdate-${container-name}" = {
            description = "timer for update-${container-name}";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "hourly";
              Persistent = true;
              Unit = "${update-service-name}.service";
            };
          };
        });
    in
    mkIf (cfg != { })
      {
        assertions = mapAttrsToList
          (container-name:
            { mac-address, ... }:
            {
              assertion = mac-address == null || strings.hasPrefix "aa" mac-address;
              message = "container ${container-name} must have mac-address with prefix \"aa\"";
            }
          )
          cfg;
        virtualisation.oci-containers.containers = mapAttrs container-cfg cfg;
        systemd = concatMapAttrsRecursive systemd-cfg containers-to-autoupdate;
      };
}
