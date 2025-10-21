{pkgs}:
pkgs.writeShellScriptBin "hp.reset" ''
  pkill -9 swww
  pkill -9 hyprpanel
  pkill -9 hyprpanel
  sleep 0.5
  hyprpanel &> /dev/null &

''
