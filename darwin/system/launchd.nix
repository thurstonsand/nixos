{
  launchd.user.agents.brew-autoupdate = {
    serviceConfig = {
      ProgramArguments = ["${./scripts/brew-autoupdate.sh}"];
      RunAtLoad = true;
      KeepAlive = false;
      StandardErrorPath = "/tmp/brew-autoupdate.err.log";
      StandardOutPath = "/tmp/brew-autoupdate.log";
    };
  };
}
