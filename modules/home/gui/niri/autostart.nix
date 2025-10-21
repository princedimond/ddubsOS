{ pkgs, ... }:
{
  # Autostart commands (spawn order matters)
  spawn-at-startup = [
    [ "nm-applet" ]
    [ "blueman-applet" ]
    [ "udiskie" ]
    [ "start-polkit-agent" ]
    [ "swww-daemon" ]
    [ "swww" "img" "/home/dwilliams/Pictures/Wallpapers/astralbed.webp" "--transition-type" "any" "--transition-fps" "60" "--transition-duration" "1.0" ]
    [ "waybar" ]
  ];
}

