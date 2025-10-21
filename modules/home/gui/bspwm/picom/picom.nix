{ config
, pkgs
, ...
}: {
  services.picom = {
    enable = true;
    backend = "xrender";
    vSync = true;
    settings = {
      shadow = true;
      shadow-opacity = 0.75;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-exclude = [
        "name = 'Notification'"
        "class_g ?= 'Notify-osd'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      fading = true;
      fade-in-step = 0.03;
      fade-out-step = 0.03;
      inactive-opacity = 0.8;
      frame-opacity = 1.0;
      inactive-opacity-override = false;
      opacity-rule = [ "97:class_g = 'Geany'" ];
      corner-radius = 10;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      blur = {
        method = "kernel";
        kern = "3x3box";
        exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "_GTK_FRAME_EXTENTS@:c"
        ];
      };
      wintypes = {
        tooltip = {
          fade = true;
          shadow = true;
          opacity = 0.95;
          focus = true;
          full-shadow = false;
        };
        dock = {
          shadow = false;
          "clip-shadow-above" = true;
        };
        dnd = {
          shadow = false;
        };
        popup_menu = {
          opacity = 0.95;
        };
        dropdown_menu = {
          opacity = 0.95;
        };
      };
      dithered-present = false;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";
    };
  };
}
