# Hyprtrails adds a color tail on floating windows when moved.
{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    plugins = [ pkgs.hyprlandPlugins.hyprtrails ];
    settings = {
      plugin = {
        hyprtrails = {
          color = "rgba(33ccff80)";
          bezier_step = 0.1;
          points_per_step = 2;
          history_points = 20;
          history_step = 2;
        };
      };
    };
  };
}
