#!/usr/bin/env bash
set -euo pipefail

# Small rofi-based power menu tailored for Niri
# - Logout: terminate only the current session (back to SDDM)
# - Reboot/Shutdown: use systemd user-friendly actions

choice=$(printf "%s\n" \
  "  Lock" \
  "󰍃  Logout" \
  "󰜉  Reboot" \
  "  Shutdown" \
  | rofi -dmenu -p "Power" -theme-str 'window { width: 22em; } listview { lines: 4; }' || true)

case "${choice:-}" in
  "  Lock")
    command -v swaylock >/dev/null 2>&1 && exec swaylock || exit 0
    ;;
  "󰍃  Logout")
    # Try graceful exit first, then fallbacks to ensure SDDM returns
    # 1) Ask Niri to quit gracefully (if msg is available)
    if command -v niri >/dev/null 2>&1; then
      niri msg action quit >/dev/null 2>&1 || true
      sleep 0.3
    fi
    # 2) Stop user service if managed by systemd --user
    systemctl --user stop niri.service >/dev/null 2>&1 || true
    sleep 0.2
    # 3) Terminate the session so the DM takes over
    if [ -n "${XDG_SESSION_ID:-}" ]; then
      loginctl terminate-session "$XDG_SESSION_ID" >/dev/null 2>&1 || \
      loginctl kill-session "$XDG_SESSION_ID" >/dev/null 2>&1 || true
    else
      loginctl terminate-user "$USER" >/dev/null 2>&1 || true
    fi
    # 4) As last resort, kill remaining compositor processes
    pkill -x niri-session >/dev/null 2>&1 || true
    pkill -x niri >/dev/null 2>&1 || true
    exit 0
    ;;
  "󰜉  Reboot")
    exec systemctl reboot
    ;;
  "  Shutdown")
    exec systemctl poweroff
    ;;
  *)
    exit 0
    ;;
esac
