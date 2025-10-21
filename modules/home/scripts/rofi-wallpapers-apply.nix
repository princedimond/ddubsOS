{ pkgs }:
pkgs.writeShellScriptBin "rofi-wallpapers-apply" ''
  #!/usr/bin/env bash
  set -euo pipefail

  sel="$(rofi-wallpapers || true)"
  if [ -n "''${sel:-}" ]; then
    # Ensure selected image covers the screen (preserve aspect; crop if needed)
    exec ${pkgs.swww}/bin/swww img --resize fill "$sel"
  fi
''

