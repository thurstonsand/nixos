{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      ack
      fh
      git-credential-manager
      git-crypt
      # TODO: remove the override once this bug is fixed
      # got error where zlib headers were not found
      (pkgs.git-trim.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [pkgs.zlib];
      }))
      nix-prefetch-github
      prettyping
      tldr
      unzip
    ];
    stateVersion = "23.05";
  };

  programs = {
    home-manager.enable = true;

    bash.enable = true;

    bat.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      ignores = [
        ".DS_Store"
        ".vscode"
        ".cache"
        ".nix"
      ];
      userName = "Thurston Sandberg";
      userEmail = "thurstonsand@gmail.com";
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GpY+hdZp60Fbnk9B03sntiJRx7OgLwutV5vJpV6P+";
        signByDefault = true;
      };
      lfs.enable = true;
      extraConfig = {
        color.ui = "auto";
        credential.helper = "/usr/local/share/gcm-core/git-credential-manager";
        gpg.format = "ssh";
        "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        init.defaultBranch = "main";
        pull.rebase = true;
        push = {
          default = "simple";
          autoSetupRemote = true;
        };
      };
    };

    htop.enable = true;

    nvchad = {
      enable = true;
      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        (python3.withPackages (ps:
          with ps; [
            python-lsp-server
            flake8
          ]))
      ];

      chadrcConfig = ''
        ---@type ChadrcConfig
        local M = {}

        M.ui = {
          theme = 'catppuccin',
          transparency = true,
        }

        return M
      '';

      hm-activation = true;
      backup = false;
    };

    ripgrep = {
      enable = true;
    };

    starship = {
      enable = true;
      settings = {
        hostname.disabled = true;
        username.disabled = true;
      };
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [vim-nix vim-lastplace];
      defaultEditor = false; # try to use neovim instead
      extraConfig = builtins.readFile ./dotfiles/.vimrc;
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        size = 1000;
        save = 10000;
      };

      shellAliases = {
        "ll" = "ls -l";
        "la" = "ls -al";
        "l" = "eza -F";
        "ping" = "prettyping";
        "top" = "htop";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd j"
      ];
    };
  };
}
