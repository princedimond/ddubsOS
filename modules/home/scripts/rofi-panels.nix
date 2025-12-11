{pkgs}:
pkgs.writeShellScriptBin "rofi-panels" ''
  #!/usr/bin/env bash
  set -euo pipefail

  # Detect active panel
  active=""
  if pgrep -x hyprpanel >/dev/null 2>&1; then active="hyprpanel"; fi
  if pgrep -x waybar >/dev/null 2>&1; then active="waybar"; fi
  if pgrep -x dms >/dev/null 2>&1 || pgrep -fa dms | grep -q "\bdms\b.*\brun\b"; then active="dms"; fi
  if pgrep -fa quickshell | grep -q "noctalia-shell"; then active="noctalia"; fi

  mark() {
    local key="$1" label="$2"
    if [ "$active" = "$key" ]; then
      printf "* %s\n" "$label"
    else
      printf "%s\n" "$label"
    fi
  }

  # Build 4 entries, two columns via theme override
  tmp=$(mktemp)
  {
    mark noctalia "Noctalia"
    mark dms      "DMS"
    mark waybar   "Waybar"
    mark hyprpanel "Hyprpanel"
  } >"$tmp"

  # Choose
  CHOICE=$(ROFI_CONFIG="$HOME/.config/rofi/menu.config.rasi" \
    rofi -dmenu -p "Panels (''${active:-none})" -i \
         -config "$HOME/.config/rofi/menu.config.rasi" \
         -theme-str 'window { width: 44ch; location: center; } listview { columns: 2; lines: 2; spacing: 8; dynamic: false; } element { padding: 6; } element-icon { size: 0; } element-text { expand: true; horizontal-align: 0.5; } entry { enabled: false; } inputbar { children: [ prompt ]; } prompt { enabled: true; }' \
         <"$tmp" || true)

  rm -f "$tmp"
  CHOICE=''${CHOICE#* } # strip optional leading '* '

  # Resolve runner path explicitly to avoid PATH discrepancies
  run_and_exit() {
    local bin
    bin=$(command -v "$1" || true)
    if [ -n "$bin" ]; then
      exec "$bin"
    else
      echo "Error: $1 not found" >&2
      exit 1
    fi
  }

  case "$CHOICE" in
    Noctalia) run_and_exit noctalia-run ;;
    DMS)      run_and_exit dms-run ;;
    Waybar)   run_and_exit waybar-run ;;
    Hyprpanel)run_and_exit hyprpanel-run ;;
    *)        exit 0 ;;
  esac
''
