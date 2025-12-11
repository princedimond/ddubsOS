{
  lib,
  pkgs,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  enableSway = vars.enableSway or false;
  # We provide GTK portal always; add wlr portal when Sway is enabled.
  wlrPortals = lib.optional enableSway pkgs.xdg-desktop-portal-wlr;
  extra = [pkgs.xdg-desktop-portal-gtk] ++ wlrPortals;
in {
  xdg.portal = {
    enable = true;
    extraPortals = extra;
  };
}
