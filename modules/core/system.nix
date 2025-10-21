{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) consoleKeyMap;
in
{
  nix = {
    settings = {
      download-buffer-size = 250000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      allowed-users = [ "@wheel" ];
      trusted-users = [ "@wheel" ];
      #build-dir = "/var/tmp";
    };
  };
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Note to future self. Find all these and change to ddubsOS
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    DDUBSOS_VERSION = "2.5.8";
    DDUBSOS = "true";
  };

  powerManagement = {
    enable = true; # Ensure power management is enabled
    cpuFreqGovernor = "performance"; # Set the governor to performance
  };

  console.keyMap = "${consoleKeyMap}";
  system.stateVersion = "25.05"; # Do not change!
}
