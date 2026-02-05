{host, ...}: let
  hostVars = import ../../../hosts/${host}/variables.nix;
  inherit (hostVars) animChoice;
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
    ./windowrules-ng.nix
    ./rofi/default.nix
    ./swappy.nix
    ./swaync.nix
  ];
}
