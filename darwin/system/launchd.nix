{
  launchd.user.agents.brew-autoupdate = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/bin/brew"
        "autoupdate"
        "start"
        "86400"
        "--cleanup"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardErrorPath = "/tmp/brew-autoupdate.err.log";
      StandardOutPath = "/tmp/brew-autoupdate.out.log";
    };
  };
}
