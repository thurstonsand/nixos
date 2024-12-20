{pkgs, ...}: {
  home = {
    username = "deck";
    homeDirectory = "/home/deck";

    packages = with pkgs; [
      libsForQt5.plasma-browser-integration
      # this does not work
      # 00:00:00 - Qt Fatal: Could not initialize GLX
      # zsh: abort (core dumped)  moonlight
      # moonlight-qt
    ];
  };
  targets.genericLinux.enable = true;

  programs = {
    zsh.shellAliases = {
      switch = "nix run . -- switch --flake";
    };
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      extensions = with pkgs.vscode-extensions; [
        mhutchie.git-graph
        eamodio.gitlens
        jnoortheen.nix-ide
        ms-vscode-remote.remote-ssh
      ];
      mutableExtensionsDir = false;
      userSettings = {
        "editor.formatOnSave" = true;
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.allowForcePush" = true;
        "git.confirmForcePush" = false;
      };
    };

    firefox = {
      enable = true;
      package = with pkgs;
        firefox.override {
          cfg = {
            preferences = {
              "widget.use-xdg-desktop-portal.file-picker" = 1;
            };
            nativeMessagingHosts.packages = [plasma5Packages.plasma-browser-integration];
          };
        };
      # about:policies#documentation
      policies = {
        DefaultDownloadDirectory = "~/Downloads";
        DisableAppUpdate = true;
        DisablePocket = true;
        DisableProfileImport = true;
        DisableSystemAddonUpdate = true;
        DisplayBookmarksToolbar = "newtab";
        DontCheckDefaultBrowser = true;
        ExtensionUpdate = false;
        Homepage = {
          StartPage = "previous-session";
        };
        InstallAddonsPermission = {
          Default = false;
        };
        NewTabPage = false;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        PromptForDownloadLocation = false;
        SearchBar = "unified";
        StartDownloadsInTempDirectory = true;
      };
      profiles."Thurston Sandberg" = {
        isDefault = true;
        # https://nur.nix-community.org/repos/rycee/
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          kagi-search
          plasma-integration
        ];
        bookmarks = [
          {
            name = "Steam";
            url = "https://store.steampowered.com/";
          }
        ];
      };
    };
  };
}
