{ pkgs }:
pkgs.writeShellScriptBin "rofi.menu" ''
  rofi -config ~/.config/rofi/menu.config.rasi -show drun 
''
