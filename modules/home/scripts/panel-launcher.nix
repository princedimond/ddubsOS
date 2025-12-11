{pkgs}:
pkgs.writeShellScriptBin "panel-launcher" ''
  #!/usr/bin/env bash
  set -euo pipefail

  is_noctalia() { pgrep -fa quickshell | grep -q "noctalia-shell" ; }
  is_dms() { pgrep -x dms >/dev/null 2>&1 || pgrep -fa dms | grep -q "\bdms\b.*\brun\b"; }

  if is_noctalia; then
    if command -v quickshell >/dev/null 2>&1; then
      exec quickshell -c noctalia-shell ipc call launcher toggle
    else
      exec qs -c noctalia-shell ipc call launcher toggle
    fi
  elif is_dms; then
    exec dms ipc call spotlight toggle
  else
    exec rofi-launcher
  fi
''
