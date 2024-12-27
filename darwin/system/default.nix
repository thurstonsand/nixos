{pkgs, ...}: {
  imports = [
    ./enhanced-homebrew.nix
    ./homebrew.nix
    ./launchd.nix
    ./nix-core.nix
    ./packages.nix
    ./users.nix
  ];

  system = {
    stateVersion = 5;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      # customize dock
      dock = {
        autohide = true; # dock autohide
        orientation = "left"; # dock on the left
        show-process-indicators = true; # show indicators for open apps
        # tilesize = 32;  # tile size
        # magnification = false;  # show magnification
        # minimize-to-application = true;  # minimize windows into application icon
        # launchpad-animation = true;  # animate launchpad
        show-recents = false; # hide recent items
        mru-spaces = false; # show spaces in recent items
        # workspaces-columns = 4;  # number of columns in workspaces
      };

      finder = {
        _FXShowPosixPathInTitle = true; # show full path in finder title
        AppleShowAllExtensions = true; # show all file extensions
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        QuitMenuItem = true; # enable quit menu item
        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar
      };

      menuExtraClock.Show24Hour = true; # show 24 hour clock

      # TODO: keyboard section not working?
      # also: https://github.com/LnL7/nix-darwin/issues/905
      # keyboard = {
      #   # is this needed?
      #   enableKeyMapping = true; # enable key mapping so that we can use `caps lock` as `escape`

      #   # NOTE: do NOT support remap capslock to both control and escape at the same time
      #   remapCapsLockToControl = false; # remap caps lock to control, useful for emac users
      #   remapCapsLockToEscape = true; # remap caps lock to escape, useful for vim users
      # };

      # customize settings that not supported by nix-darwin directly
      # Incomplete list of macOS `defaults` commands :
      #   https://github.com/yannbertrand/macos-defaults
      NSGlobalDomain = {
        # how long it takes before key starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # sets how fast it repeats once it starts.
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
        NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
        NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
        NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction

        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      font-awesome
      nerd-fonts.mononoki
    ];
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  # enable direnv/nix develop envs
  environment.systemPackages = with pkgs; [
    nix-direnv
  ];
}
