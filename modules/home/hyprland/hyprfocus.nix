# Hyprfocus is a Hyprland plugin for focus animations and effects
{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    # Load the Hyprfocus plugin
    plugins = [ pkgs.hyprlandPlugins.hyprfocus ];

    settings = {
      plugin = {
        hyprfocus = {
          enabled = true; # Converted from 'yes' to true
          animate_floating = true; # Converted from 'yes' to true
          animate_workspacechange = true; # Converted from 'yes' to true
          focus_animation = "shrink"; # Strings remain as-is

          # Beziers: Use a list for multiple bezier entries
          bezier = [
            "bezIn, 0.5,0.0,1.0,0.5"
            "bezOut, 0.0,0.5,0.5,1.0"
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.36, 0, 0.66, -0.56"
            "smoothIn, 0.25, 1, 0.5, 1"
            "realsmooth, 0.28,0.29,.69,1.08"
          ];

          # Flash settings as a sub-attribute
          flash = {
            flash_opacity = 0.95;
            in_bezier = "realsmooth";
            in_speed = 0.5;
            out_bezier = "realsmooth";
            out_speed = 3;
          };

          # Shrink settings as a sub-attribute
          shrink = {
            shrink_percentage = 0.95;
            in_bezier = "realsmooth";
            in_speed = 1;
            out_bezier = "realsmooth";
            out_speed = 2;
          };
        };
      };
    };
  };
}
