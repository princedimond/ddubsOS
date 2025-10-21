{ host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix) animChoice;
in
{
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
    ./windowrules.nix
    #./hyprexpo.nix   $# Won't build 9/13/25
    #./hyprtrails.nix  # Getting blob effects off for now
    #./hyprspace.nix
    ./rofi/default.nix
    ./swappy.nix
    ./swaync.nix
  ];
}
