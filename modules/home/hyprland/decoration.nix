{...}: {
  wayland.windowManager.hyprland = {
    settings = {
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          xray = true;
          ignore_opacity = true;
          new_optimizations = true;
          popups = true;
          special = true;
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
