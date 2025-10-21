{ pkgs, ... }:
let
  enableNwgApps = true; # Set to true to enable the configuration
in
{
  home.packages =
    with pkgs;
    (
      if enableNwgApps then
        [
          # Python update causing build failures 8/25/25
          #nwg-menu
          #nwg-bar
          nwg-dock-hyprland
          nwg-launchers
          #nwg-clipman
          nwg-panel
          nwg-displays
        ]
      else
        [ ]
    );
}
