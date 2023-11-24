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
      firefox
      gh
      git
      htop
      nix-prefetch-github
      tldr
      unzip
      thefuck
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
      # prezto = {
      # enable = true;
      # prompt = {
      # showReturnVal = true;
      # theme = "adam1";
      # };
      #   pmodules = [
      #     "environment"
      #     "terminal"
      #     "editor"
      #     "history"
      #     "directory"
      #     "spectrum"
      #     "utility"
      #     "completion"
      #     "prompt"
      #     "syntax-highlighting"
      #     "git"
      #     "fasd"
      #   ];
      # };
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
    git-credential-oauth.enable = true;

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
