macvlan-name:
{ config, lib, ... }:
with lib;
let
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
        description = lib.mdDoc ''
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
        description = lib.mdDoc "Override the default entrypoint of the image.";
        default = null;
        example = "/bin/my-app";
      };

      cmd = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = lib.mdDoc "Commandline arguments to pass to the image's entrypoint.";
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
          to the macvlan passed in to this module.
        '';
        example = "192.168.1.5";
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

  config = mkIf (cfg != { }) {
    virtualisation.oci-containers.containers = builtins.mapAttrs
      (container-name:
        opts@{ ip, capAdd, devices, extraOptions, ... }:
        let
          netOptions = lists.optionals (ip != null) [
            "--network=${macvlan-name}"
            "--ip=${ip}"
          ];
          capAddOptions = builtins.map (cap: "--cap-add=${cap}") capAdd;
          devicesOptions = builtins.map (device: "--device=${device}") devices;
          nonEmpty = value: value != null && value != [ ] && value != { };
          addIfExists = opts: attrsets.foldlAttrs (attrs: key: value: attrs // attrsets.optionalAttrs (nonEmpty value) { "${key}" = value; }) { } opts;
        in
        {
          autoStart = true;
          extraOptions = extraOptions ++ netOptions ++ capAddOptions ++ devicesOptions;
        } // addIfExists { inherit (opts) image imageFile entrypoint cmd environment ports user volumes dependsOn; })
      cfg;
  };
}
