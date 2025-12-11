#!/usr/bin/env bash
# Rofi-based power menu for Sway
set -euo pipefail

SYSTEMCTL="/run/current-system/sw/bin/systemctl"
SWAYMSG="${SWAYMSG:-$(command -v swaymsg || true)}"

ROFI_THEME="$HOME/.config/rofi/power-menu.rasi"
ACTIONS=$(cat <<'EOF'
  Lock
  Shutdown
  Reboot
  Suspend
  Hibernate
󰞘  Logout
EOF
)

if [ -f "$ROFI_THEME" ]; then
  SELECTED=$(echo -e "$ACTIONS" | rofi -dmenu -i -p "Power" -config "$ROFI_THEME" || true)
else
  SELECTED=$(echo -e "$ACTIONS" | rofi -dmenu -i -p "Power" || true)
fi

# Match by keyword anywhere in the selected line for robustness
case "${SELECTED:-}" in
  *Lock*)
    exec /run/current-system/sw/bin/loginctl lock-session
    ;;
  *Shutdown*)
    exec ${SYSTEMCTL} poweroff
    ;;
  *Reboot*)
    exec ${SYSTEMCTL} reboot
    ;;
  *Suspend*)
    exec ${SYSTEMCTL} suspend
    ;;
  *Hibernate*)
    exec ${SYSTEMCTL} hibernate
    ;;
  *Logout*)
    # Prefer exiting the compositor directly
    if [ -n "${SWAYMSG}" ]; then
      exec "${SWAYMSG}" exit
    fi
    # Fallback: end the user's systemd session
    exec /run/current-system/sw/bin/loginctl terminate-user "$USER"
    ;;
  *)
    exit 0
    ;;
esac
