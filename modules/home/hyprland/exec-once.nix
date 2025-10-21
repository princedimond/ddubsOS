{ host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix) panelChoice stylixImage;
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Common startup commands
      "wl-paste --type text --watch cliphist store" # Saves text
      "wl-paste --type image --watch cliphist store" # Saves images
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user start hyprpolkitagent"

      # Kill notification daemons that might conflict
      "killall -q dunst"
      "pkill dunst"
      "killall -q mako"
      "pkill mako"
      "sleep 1"
    ]
    ++
      # Conditional panel-specific commands
      (
        if panelChoice == "hyprpanel" then
          [
            "hyprpanel"
            "qs-wallpapers-restore || waypaper --wallpaper ${stylixImage} --backend swaybg"
          ]
        else
          [
            "killall -q swww;sleep .5 && swww-daemon"
            "killall -q waybar;sleep .5 && waybar"
            #"wallsetter &"
            "qs-wallpapers-restore || waypaper --wallpaper ${stylixImage} --backend swww"
            "nm-applet --indicator"
          ]
      )
    ++ [
      # Common post-panel commands
      "copyq --server"
      "pypr &" # pyprland for drop down term SUPERSHIFT + T
      #"eww daemon"  # For future maybe Prob Quick Shell b4 that
    ];
  };
}
