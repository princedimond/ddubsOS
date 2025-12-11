{pkgs}:
pkgs.writeShellScriptBin "noctalia-run" ''
  #!/usr/bin/env bash
  set -euo pipefail

  is_noctalia() {
    pgrep -fa quickshell | grep -q "noctalia-shell" 2>/dev/null
  }

  kill_noctalia() {
    pkill -f "noctalia-shell" 2>/dev/null || true
    pkill -x quickshell 2>/dev/null || true
    sleep 0.3
    if pgrep -fa noctalia-shell >/dev/null 2>&1; then pkill -9 -f noctalia-shell 2>/dev/null || true; fi
  }

  # Stop conflicting panels/bars
  stop_conflicts() {
    pkill -x hyprpanel 2>/dev/null || true

    # Kill Waybar aggressively (wrapper or store paths)
    pkill -x waybar 2>/dev/null || true
    pkill -f '[/]waybar( |$)' 2>/dev/null || true
    pkill -f 'waybar.*' 2>/dev/null || true
    killall -q waybar 2>/dev/null || true

    pkill -x dms 2>/dev/null || true

    # Noctalia (QuickShell) specific: ensure previous instance is gone
    kill_noctalia

    # Notification daemon conflicts (often used with waybar)
    pkill -x swaync 2>/dev/null || true

    # Wait briefly for waybar to exit fully
    for i in 1 2 3 4 5 6; do
      if pgrep -x waybar >/dev/null 2>&1 || pgrep -fa waybar >/dev/null 2>&1; then
        sleep 0.2
      else
        break
      fi
    done
  }

  # If noctalia already active, just exit successfully
  if is_noctalia; then
    exit 0
  fi

  stop_conflicts
  sleep 0.3

  # Launch Noctalia QuickShell config
  # Use nohup+setsid to detach and avoid being killed with the parent shell
  if command -v quickshell >/dev/null 2>&1; then
    nohup setsid quickshell -c noctalia-shell >/dev/null 2>&1 &
  elif command -v qs >/dev/null 2>&1; then
    nohup setsid qs -c noctalia-shell >/dev/null 2>&1 &
  else
    echo "Error: quickshell/qs not found" >&2
    exit 1
  fi
''
