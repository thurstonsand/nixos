{ pkgs, ... }:

{
  # home-manager options: https://mipmip.github.io/home-manager-option-search/
  imports = [ ];

  home = {
    username = "thurstonsand";
    homeDirectory = "/home/thurstonsand";
    packages = with pkgs; [
      git-crypt
      fh
      git-trim
      nix-prefetch-github
      tldr
      unzip
    ];
  };

  programs = {
    home-manager.enable = true;

    # shell
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
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
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

    # edit
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-nix vim-lastplace ];
      defaultEditor = true;
      extraConfig = builtins.readFile ./dotfiles/.vimrc;
    };

    # manage
    htop.enable = true;
    git = {
      enable = true;
      userName = "Thurston Sandberg";
      userEmail = "thurstonsand@hey.com";
      ignores = [ ".direnv" ];
      diff-so-fancy = {
        enable = true;
      };
      extraConfig = {
        color = {
          ui = "auto";
        };
        push = {
          default = "simple";
          autoSetupRemote = "true";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
  };

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
