# Hyprscrollinmg  adds niri like layout.
{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    plugins = [ pkgs.hyprlandPlugins.hyprscrolling ];
  };
}
