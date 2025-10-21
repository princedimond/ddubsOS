{ pkgs }:
# Start gnome polkit needed for niri and waybar
pkgs.writeShellScriptBin "start-polkit-agent" ''
  #!/usr/bin/env bash
  ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
''
