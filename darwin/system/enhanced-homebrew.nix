{
  config,
  lib,
  pkgs,
  ...
}: {
  options = with lib; {
    homebrew.validateMasApps = mkOption {
      type = types.bool;
      default = false;
      description = "If true, validates that the configured Mac App Store apps match what is installed on the system";
    };
  };
  config = let
    cfg = config.homebrew;

    configuredIds = with builtins; map toString (attrValues cfg.masApps);
    checkMASApps = pkgs.writeShellScript "check-mas-apps" ''
      set -e
      INSTALLED_IDS=$(${pkgs.mas}/bin/mas list | awk '{print $1}' | sort)
      CONFIGURED_IDS="${builtins.concatStringsSep "\n" configuredIds}"

      MISSING_IDS=$(comm -23 <(echo "$CONFIGURED_IDS" | sort) <(echo "$INSTALLED_IDS"))
      EXTRA_IDS=$(comm -13 <(echo "$CONFIGURED_IDS" | sort) <(echo "$INSTALLED_IDS"))

      if [ -n "$MISSING_IDS" ]; then
        echo "Apps should have been installed, but were not:"
        while IFS= read -r id; do
          [ -n "$id" ] && echo "  $id ($(${pkgs.mas}/bin/mas info "$id" | head -n 1))"
        done <<< "$MISSING_IDS"
        exit 1
      fi
      if [ -n "$EXTRA_IDS" ]; then
        echo "Apps are installed, but not mentioned in the nix config:"
        while IFS= read -r id; do
          [ -n "$id" ] && echo "  $id ($(${pkgs.mas}/bin/mas info "$id" | head -n 1))"
        done <<< "$EXTRA_IDS"
        exit 1
      fi

      echo "All configured apps are properly installed"
    '';
  in
    lib.mkIf (cfg.enable && cfg.validateMasApps) {
      system.activationScripts.postUserActivation.text = ''
        #!${pkgs.bash}/bin/bash
        echo "Checking Mac App Store apps..."
        ${checkMASApps}
      '';
    };
}
