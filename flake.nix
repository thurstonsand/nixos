{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
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
    };
}
