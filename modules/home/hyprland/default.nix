{host, ...}: let
  hostVars = import ../../../hosts/${host}/variables.nix;
  inherit (hostVars) animChoice;
  enableHyprlandSource = hostVars.enableHyprlandSource or false;
  windowrulesModule =
    if enableHyprlandSource
    then ./windowrules-ng.nix
    else ./windowrules.nix;
in {
  imports = [
    animChoice
    ./agsv1.nix
    ./emoji.nix
    ./ewww.nix
    ./xdg.nix
    ./binds.nix
    ./cursor-render.nix
    ./decoration.nix
    ./env.nix
    ./exec-once.nix
    ./gestures.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./misc.nix
    ./nwg-dock.nix
    ./nwg-apps.nix
    ./pyprland.nix
    windowrulesModule
    #./hyprexpo.nix   $# Won't build 9/13/25
    #./hyprtrails.nix  # Getting blob effects off for now
    #./hyprspace.nix
    ./rofi/default.nix
    ./swappy.nix
    ./swaync.nix
  ];
}
