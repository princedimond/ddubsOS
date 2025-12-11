{pkgs, ...}:
pkgs.writeShellScriptBin "toggle-idle" ''
  IDLE_PID=$(${pkgs.procps}/bin/pgrep hypridle)

  if [ -z "$IDLE_PID" ]; then
      # hypridle is not running, so start it (inhibit is effectively off)
      ${pkgs.hypridle}/bin/hypridle &
      # You might also want a notification here
      ${pkgs.libnotify}/bin/notify-send "Idle Inhibitor" "Idle management ENABLED."
  else
      # hypridle is running, so kill it (inhibit is effectively ON)
      ${pkgs.killall}/bin/killall hypridle
      ${pkgs.libnotify}/bin/notify-send "Idle Inhibitor" "Idle management DISABLED (Inhibit ON)."
  fi
''
