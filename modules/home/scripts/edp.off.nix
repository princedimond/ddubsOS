{pkgs}:
pkgs.writeShellScriptBin "edp.off" ''
  hyprctl keyword monitor "eDP-1, disable"
  hp.reset
''
