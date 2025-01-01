# Setting up MacOS

1. [Install Homebrew](https://brew.sh/)
2. [Install Nix](https://github.com/DeterminateSystems/nix-installer):
   ```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
   sh -s -- install
   ```
3. Download the git repo:
   ```
   mkdir -p ~/Develop
   git clone git@github.com:thurstonsand/nixos.git ~/Develop
   ```
4. Run:
   ```
   nix run nix-darwin -- switch --flake ~/Develop/nixos
   ```
5. [Setup 1Password CLI](https://developer.1password.com/docs/cli/get-started) for git keys (start from step 2)
6. You can use `switch` from now on to upgrade