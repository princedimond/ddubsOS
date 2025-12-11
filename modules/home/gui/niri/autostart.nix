{pkgs, ...}: {
  # Autostart commands (spawn order matters) based on config.kdl
  spawnAtStartup = [
    ["nm-applet"]
    ["blueman-applet"]
    ["udiskie"]
    ["/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"]
    ["swww-daemon"]
    # ["waybar-niri"]
    # ["dms" "run"]
    ["noctalia-shell"]
    # Required for clipboard history integration
    ["bash" "-c" "wl-paste --watch cliphist store &"]
    # Restore last wallpaper after bar starts
    ["waypaper" "--restore"]
  ];
  # spawn-sh-at-startup = [ "$pkgs.dms-shell}/bin/dms run" ];
}
