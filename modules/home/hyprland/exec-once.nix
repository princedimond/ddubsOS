{host, ...}: let
  inherit (import ../../../hosts/${host}/variables.nix) panelChoice stylixImage;
in {
  wayland.windowManager.hyprland.settings = {
    exec-once =
      [
        # Common startup commands
        "wl-paste --type text --watch cliphist store" # Saves text
        "wl-paste --type image --watch cliphist store" # Saves images
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        # Varity is starting up with hyprland maybe via dex?
        "pkill variety"

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
        if panelChoice == "noctalia"
        then [
          "killall -q hyprpanel"
          "pkill hyprpanel"
          "killall -q waybar"
          "pkill waybar"
          "killall -q swaync"
          "pkill swaync"
          "noctalia-shell &"
        ]
        else if panelChoice == "dms"
        then [
          "killall -q hyprpanel"
          "pkill hyprpanel"
          "killall -q waybar"
          "pkill waybar"
          "killall -q swaync"
          "pkill swaync"
          "dms-run"
        ]
        else if panelChoice == "hyprpanel"
        then [
          "hyprpanel"
          # Note: wallpaper restore is intentionally NOT run for hyprpanel
        ]
        else [
          # waybar branch: delayed-only restore so Stylix completes first, then user's wallpaper wins
          "killall -q swww;sleep .5 && swww-daemon"
          "killall -q waybar;sleep .5 && waybar"
          #"wallsetter &"
          "sh -lc 'sleep 2 && (qs-wallpapers-restore || waypaper --wallpaper ${stylixImage} --backend swww) >/dev/null 2>&1 || true'"
          "nm-applet --indicator"
        ]
      )
      ++ [
        # Common post-panel commands
        # Start quickshell-overview daemon
        "qs -c overview"
        # Initialize dropdown terminal after TERM is available (fallback to kitty)
        "sh -lc 'DropTerminal --spawn-only'"
      ];
  };
}
