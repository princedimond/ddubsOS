#!/usr/bin/env bash
set -euo pipefail

# Remove Google Chrome machine policy that triggers "Managed by your organization"
# Specifically removes /etc/opt/chrome/policies/managed/extra.json if present.
# On NixOS, this symlink typically points into /etc/static/... which in turn points
# into /nix/store. We remove the active policy symlink. If the policy is declared
# in your NixOS config, it can reappear after a rebuild; remove the declaration
# (environment.etc."opt/chrome/policies/managed/extra.json") to prevent that.

POLICY_LINK="/etc/opt/chrome/policies/managed/extra.json"
STATIC_TARGET=""

echo "[chrome-policy] Checking for machine policy at ${POLICY_LINK}"
if [ -L "${POLICY_LINK}" ] || [ -f "${POLICY_LINK}" ]; then
  if command -v readlink >/dev/null 2>&1; then
    STATIC_TARGET=$(readlink -f "${POLICY_LINK}" || true)
  fi
  echo "[chrome-policy] Removing ${POLICY_LINK} (requires sudo)"
  sudo rm -f "${POLICY_LINK}" || {
    echo "[chrome-policy] Warning: failed to remove ${POLICY_LINK}" >&2
  }
else
  echo "[chrome-policy] No active policy file at ${POLICY_LINK}"
fi

if [ -n "${STATIC_TARGET}" ] && [ -e "${STATIC_TARGET}" ]; then
  echo "[chrome-policy] Policy link target was: ${STATIC_TARGET}"
  if [[ "${STATIC_TARGET}" == /nix/store/* ]]; then
    echo "[chrome-policy] Target is in /nix/store (immutable). Not removing."
  else
    echo "[chrome-policy] Attempting to remove target ${STATIC_TARGET} (requires sudo)"
    sudo rm -f "${STATIC_TARGET}" || true
  fi
fi

# Show any remaining managed policy files for visibility
MANAGED_DIR="/etc/opt/chrome/policies/managed"
if [ -d "${MANAGED_DIR}" ]; then
  echo "[chrome-policy] Remaining managed policy files:"
  ls -la "${MANAGED_DIR}" || true
fi

cat <<'EONOTE'
[chrome-policy] Done.
Now open chrome://policy and click "Reload policies" (or restart Chrome).
If the policy returns after a NixOS rebuild, search your configuration for a stanza like:
  environment.etc."opt/chrome/policies/managed/extra.json".text = ''{"BrowserThemeColor":"#191837"}'';
and remove or change it, then run:
  sudo nixos-rebuild switch
EONOTE
