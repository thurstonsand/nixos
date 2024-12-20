{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      git-crypt
      fh
      git-trim
      nix-prefetch-github
      nixpkgs-fmt
      tldr
      unzip
    ];
    stateVersion = "23.05";
  };

  programs = {
    home-manager.enable = true;

    # shell
    bash.enable = true;
    zsh = {
      enable = true;
      autosuggestion.enable = true;
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
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # edit
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [vim-nix vim-lastplace];
      defaultEditor = true;
      extraConfig = builtins.readFile ./dotfiles/.vimrc;
    };

    # manage
    htop.enable = true;
    git = {
      enable = true;
      userName = "Thurston Sandberg";
      userEmail = "thurstonsand@gmail.com";
      ignores = [".direnv"];
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

        # signing with 1password
        gpg = {
          format = "ssh";
        };
        commit = {
          gpgsign = true;
        };
        user = {
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GpY+hdZp60Fbnk9B03sntiJRx7OgLwutV5vJpV6P+";
        };
      };
    };
  };
}
