{ inputs, lib, config, pkgs, ... }:

{
  # home-manager options: https://mipmip.github.io/home-manager-option-search/
  imports = [ ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home = {
    username = "thurstonsand";
    homeDirectory = "/home/thurstonsand";
    packages = with pkgs; [
      fh
      firefox
      git
      git-trim
      htop
      nix-prefetch-github
      starship
      tldr
      unzip
    ];
  };

  programs = {
    home-manager.enable = true;
    bash.enable = true;
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      shellAliases = {
        ll = "ls -l";
        la = "ls -al";
      };
    };
    starship = {
      enable = true;
      settings = {
        hostname = {
          disabled = true;
        };
        username = {
          disabled = true;
        };
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd j"
      ];
    };
    fzf =
      {
        enable = true;
        enableZshIntegration = true;
      };

    htop.enable = true;
    git = {
      enable = true;
      userName = "Thurston Sandberg";
      userEmail = "thurstonsand@hey.com";
      diff-so-fancy = {
        enable = true;
      };
      extraConfig = {
        color = {
          ui = "auto";
        };
        push = {
          default = "simple";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
      };
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-nix vim-lastplace ];
      defaultEditor = true;
      extraConfig = builtins.readFile ./apps/vim/.vimrc;
    };

  };

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
