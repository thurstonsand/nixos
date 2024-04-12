{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:nixos/nixpkgs/nixos-unstable?dir=lib";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    vscode-server = {
      # url = "github:nix-community/nixos-vscode-server";
      # waiting on this PR to land
      # https://github.com/nix-community/nixos-vscode-server/pull/78
      url = "github:Ten0/nixos-vscode-server/support_new_vscode_versions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , flake-utils
    , home-manager
    , nur
    , vscode-server
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
      ];
      flake = {
        nixosConfigurations.knownapps = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules = [
              ./nas/system
              ./nas/containers
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.thurstonsand = {
                  imports = [
                    (import ./common/home.nix)
                    (import ./nas/home.nix)
                  ];
                };
              }
              vscode-server.nixosModules.default
              {
                services.vscode-server.enable = true;
              }
            ];
          };
        homeConfigurations = {
          "deck" = home-manager.lib.homeManagerConfiguration {
            modules = [
              {
                nixpkgs.overlays = [ nur.overlay ];
              }
              ./common/home.nix
              ./steamdeck/home.nix
            ];
          };
        };
      };
      perSystem = { config, pkgs, system, ... }: {
        packages.default = home-manager.defaultPackage."${system}";
        devShells.default = with pkgs; mkShell {
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
          nativeBuildInputs = with pkgs.buildPackages; [
            rustc
            cargo
          ];
        };
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
      };
    };
}
