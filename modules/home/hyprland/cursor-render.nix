{ ... }: {
  wayland.windowManager.hyprland = {
    settings = {
      opengl = {
        nvidia_anti_flicker = true;
      };
      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = true;
        warp_on_change_workspace = 2;
        no_warps = true;
        inactive_timeout = 5;
      };
      render = {
        direct_scanout = 0;
        send_content_type = false;
      };
    };
  };
}
