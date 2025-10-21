{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      gestures = {
        # Hyprland 0.51+ gesture syntax
        gesture = [ "3, horizontal, workspace" ];
        workspace_swipe_distance = 500;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = true;
      };
    };
  };
}
