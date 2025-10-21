{ ... }: {
  wayland.windowManager.hyprland = {
    settings = {
      decoration = {
        rounding = 0;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };
    };
  };
}
