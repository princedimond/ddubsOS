{ pkgs }:
pkgs.writeShellScriptBin "swap_layout" ''
  #  hyprctl getoption general:layout | grep "str: master" && hyprctl keyword general:layout dwindle || hyprctl keyword general:layout master

    hyprctl getoption general:layout | grep "str: master" && \
      (hyprctl keyword general:layout dwindle && notify-send "Layout switched to Dwindle") || \
      (hyprctl keyword general:layout master && notify-send "Layout switched to Master")

''
