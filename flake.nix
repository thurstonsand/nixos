{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nur
    , vscode-server
    , ...
    }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # Allow unfree packages
        config.allowUnfree = true;
      };
      nur-no-pkgs = import nur {
        nurpkgs = pkgs;
      };
    in
    {
      nixosConfigurations.knownapps = lib.nixosSystem {
        # https://nixos.wiki/wiki/NixOS_modules
        modules = [
          {
            nixpkgs.pkgs = pkgs;
          }
          ./nas/system
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

      packages.x86_64-linux.default = home-manager.defaultPackage.x86_64-linux;
      homeConfigurations = {
        "deck" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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
}
