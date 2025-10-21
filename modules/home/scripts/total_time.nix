{ pkgs }:
let
  totalUptime = import ./total-uptime.nix { inherit pkgs; };
in
pkgs.writeShellScriptBin "total_time" ''
  set -euo pipefail
  if [[ $# -gt 0 ]]; then
    exec "${totalUptime}/bin/total-uptime" "$@"
  else
    exec "${totalUptime}/bin/total-uptime" --fastfetch
  fi
''

