{ pkgs }:
pkgs.writeShellScriptBin "niri-startup" ''

  # Start swww
  swww-daemon &

  waypaper --restore &
  #swaybg -i -m fill ~/Pictures/Wallpapers/Anime-Lanscape.png

  #  pkill waybar
  #pkill mako
  #sleep 0.3

  # Apply themes
  # ~/.config/niri/scripts/gtkthemes &
  #~/.config/niri/scripts/gtkthemes-manual &

  # Launch notification daemon (mako)
  #~/.config/niri/scripts/notifications &

  nm-applet --indicator &

''
