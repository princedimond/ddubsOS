{pkgs}:
pkgs.writeShellScriptBin "dms-run" ''
  #!/usr/bin/env bash
  set -euo pipefail

  is_noctalia() {
    pgrep -fa quickshell | grep -q "noctalia-shell" 2>/dev/null
  }

  kill_noctalia() {
    pkill -f noctalia-shell 2>/dev/null || true
    pkill -x quickshell 2>/dev/null || true
    sleep 0.3
    if pgrep -fa noctalia-shell >/dev/null 2>&1; then pkill -9 -f noctalia-shell 2>/dev/null || true; fi
  }

  stop_conflicts() {
    pkill -x hyprpanel 2>/dev/null || true
    pkill -x waybar 2>/dev/null || true
    killall -q waybar 2>/dev/null || true
    kill_noctalia
    # Kill existing DMS instance when switching within DMS
    pkill -x dms 2>/dev/null || true
    # Notification daemon conflicts
    pkill -x swaync 2>/dev/null || true
  }

  # If DMS already running, just exit
  if pgrep -fa "(^| )dms( |$).* run" >/dev/null 2>&1 || pgrep -x dms >/dev/null 2>&1; then
    exit 0
  fi

  stop_conflicts

  # Wait for waybar to exit to avoid overlap
  for i in 1 2 3 4 5; do
    if pgrep -x waybar >/dev/null 2>&1; then sleep 0.2; else break; fi
  done

  # Launch Dank Material Shell
  if command -v dms >/dev/null 2>&1; then
    nohup setsid dms run >/dev/null 2>&1 &
  else
    echo "Error: dms not found" >&2
    exit 1
  fi
''
