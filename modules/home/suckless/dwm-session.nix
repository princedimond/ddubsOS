{
  lib,
  pkgs,
  host,
  ...
}: let
  # Note: this file is at modules/home/suckless, so we need to go up three levels to reach top-level hosts/
  inherit (import ../../../hosts/${host}/variables.nix) dwmEnable;
  suckless-pkgs = import ./pkgs.nix {inherit pkgs;};
  dwmBin = "${suckless-pkgs.dwm}/bin/dwm";
in
  lib.mkIf dwmEnable {
    # Enable the built-in DWM module and use our custom build.
    # This avoids duplicate sessions by not registering an extra xsessions entry.
    services.xserver.windowManager.dwm.enable = true;
    services.xserver.windowManager.dwm.package = suckless-pkgs.dwm;
  }
