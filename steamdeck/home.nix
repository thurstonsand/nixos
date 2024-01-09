{ pkgs, ... }:

{
  home = {
    username = "deck";
    homeDirectory = "/home/deck";

    packages = with pkgs; [
      fh
      nixpkgs-fmt
      libsForQt5.plasma-browser-integration
    ];

    stateVersion = "23.11";
  };
  targets.genericLinux.enable = true;

  programs = {
    home-manager.enable = true;

    bash.enable = true;
    zsh = {
      enable = true;
      shellAliases = {
        switch = "nix run . -- switch --flake";
      };
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
      };
    };

    firefox = {
      enable = true;
      package = with pkgs; firefox.override {
        cfg = {
          preferences = {
            "widget.use-xdg-desktop-portal.file-picker" = 1;
          };
          nativeMessagingHosts.packages = [ plasma5Packages.plasma-browser-integration ];
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
          { name = "Steam"; url = "https://store.steampowered.com/"; }
        ];
      };
    };
  };
}
