{pkgs}:
pkgs.writeShellScriptBin "hyprpanel-run" ''
  #!/usr/bin/env bash
  set -euo pipefail

  kill_noctalia() {
    pkill -f noctalia-shell 2>/dev/null || true
    pkill -x quickshell 2>/dev/null || true
    sleep 0.3
    if pgrep -fa noctalia-shell >/dev/null 2>&1; then pkill -9 -f noctalia-shell 2>/dev/null || true; fi
  }

  stop_conflicts() {
    pkill -x waybar 2>/dev/null || true
    killall -q waybar 2>/dev/null || true
    pkill -x dms 2>/dev/null || true
    kill_noctalia
    # Stop existing hyprpanel to avoid duplicate instances
    pkill -x hyprpanel 2>/dev/null || true
    # Notifications can conflict visually; follow exec-once precedent and stop swaync
    pkill -x swaync 2>/dev/null || true
  }

  # If hyprpanel already running, just exit
  if pgrep -x hyprpanel >/dev/null 2>&1; then
    exit 0
  fi

  stop_conflicts
  sleep 0.2

  # Launch Hyprpanel
  if command -v hyprpanel >/dev/null 2>&1; then
    nohup setsid hyprpanel >/dev/null 2>&1 &
  else
    echo "Error: hyprpanel not found" >&2
    exit 1
  fi
''
