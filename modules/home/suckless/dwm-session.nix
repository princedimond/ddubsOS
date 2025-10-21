{ lib, config, pkgs, host, ... }:

let
  inherit (import ../../hosts/${host}/variables.nix) dwmEnable;
  suckless-pkgs = import ./pkgs.nix { inherit pkgs; };
in
let
  conditional = lib.mkIf config.services.xserver.windowManager.dwm.enable {
    services.xserver.windowManager.dwm.package = suckless-pkgs.dwm;

    environment.pathsToLink = [ "/share/xsessions" ];
    services.displayManager.sessionData.desktops =
      let
        dwm-desktop = pkgs.stdenv.mkDerivation {
          name = "dwm-desktop";
          src = ./dwm.desktop;
          installPhase = ''
            mkdir -p $out/share/xsessions
            cp $src $out/share/xsessions/dwm.desktop
          '';
        };
      in
      [ dwm-desktop ];
  };
in
{
  # Enable DWM by default when the host variable dwmEnable = true; otherwise leave disabled.
  services.xserver.windowManager.dwm.enable = lib.mkDefault dwmEnable;
}
// conditional
