#!/usr/bin/env bash
# Update vendored Warp packaging to latest upstream; safe to run anytime.
# - Computes SRI hashes and updates pkgs/warp-terminal-current/versions.json
# - Does NOT rebuild automatically; follow with `zcli rebuild`
set -euo pipefail

REPO_ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
PKG_DIR="$REPO_ROOT/pkgs/warp-terminal-current"

if [[ ! -d "$PKG_DIR" ]]; then
  echo "Error: $PKG_DIR not found" >&2
  exit 1
fi

# Ensure script is executable on first run
chmod +x "$PKG_DIR/warp-latest.sh" || true

pushd "$PKG_DIR" >/dev/null
./warp-latest.sh
popd >/dev/null

echo "Done. If updates were applied, run: zcli rebuild"
