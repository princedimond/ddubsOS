{ ... }: {
  wayland.windowManager.hyprland = {
    settings = {
      misc = {
        focus_on_activate = false;
        disable_hyprland_qtutils_check = true;
        mouse_move_focuses_monitor = true;
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        animate_manual_resizes = true;
        enable_swallow = false;
        vrr = 0;
        vfr = true;
        middle_click_paste = true;
        enable_anr_dialog = true;
        anr_missed_pings = 20;
        font_family = "Maple Mono";
      };
    };
  };
}
