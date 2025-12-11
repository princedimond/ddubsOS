{pkgs}:
pkgs.writeShellScriptBin "waybar-run" ''
  #!/usr/bin/env bash
  set -euo pipefail

  kill_noctalia() {
    pkill -f noctalia-shell 2>/dev/null || true
    pkill -x quickshell 2>/dev/null || true
    sleep 0.3
    if pgrep -fa noctalia-shell >/dev/null 2>&1; then pkill -9 -f noctalia-shell 2>/dev/null || true; fi
  }

  stop_conflicts() {
    pkill -x hyprpanel 2>/dev/null || true
    pkill -x dms 2>/dev/null || true
    kill_noctalia
    # Stop existing waybar to avoid duplicate instances
    pkill -x waybar 2>/dev/null || true
    killall -q waybar 2>/dev/null || true
  }

  # If waybar already running, just exit
  if pgrep -x waybar >/dev/null 2>&1; then
    exit 0
  fi

  stop_conflicts
  sleep 0.2

  # Launch Waybar
  if command -v waybar >/dev/null 2>&1; then
    nohup setsid waybar >/dev/null 2>&1 &
  else
    echo "Error: waybar not found" >&2
    exit 1
  fi
''
