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
          ./system
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thurstonsand = import ./home.nix;
          }
          vscode-server.nixosModules.default
          {
            services.vscode-server.enable = true;
          }
        ];
      };

      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      homeConfigurations = {
        "deck" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              nixpkgs.overlays = [ nur.overlay ];
            }
            ./steamdeck/home.nix
          ];
        };
      };
    };
}
