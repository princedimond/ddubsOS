#!/usr/bin/env bash
set -euo pipefail

: "${PBS_REPOSITORY:=root@pam@192.168.40.15:8007:PBS-LUN2}"
: "${PBS_FINGERPRINT:=4b:c6:2a:49:62:2e:c6:0d:63:0c:d1:b6:8b:78:be:af:28:2a:94:eb:d4:e7:77:ab:d1:af:c9:ea:c9:07:ef:26}"
DEFAULT_HOSTNAME=$(hostname 2>/dev/null || echo unknown-host)
DEFAULT_USER=${USER:-$(whoami 2>/dev/null || echo user)}
: "${BACKUP_ID:=${DEFAULT_HOSTNAME}-${DEFAULT_USER}-home}"

# Export env expected by proxmox-backup-client
export PBS_REPOSITORY PBS_FINGERPRINT

PBC=${PROXMOX_BACKUP_CLIENT_BIN:-proxmox-backup-client}

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") <SNAPSHOT> [TARGET_DIR] [-- additional proxmox args]" >&2
  echo "Example snapshot format: 2025-09-24T02:10:45Z" >&2
  echo "If TARGET_DIR is omitted, defaults to $HOME/restore-<SNAPSHOT>" >&2
  exit 1
fi

SNAPSHOT="$1"; shift || true
TARGET_DIR="${1:-"$HOME/restore-${SNAPSHOT}"}"
if [[ $# -ge 1 ]]; then shift; fi

if [[ -z ${PBS_PASSWORD-} ]]; then
  read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
  echo
  export PBS_PASSWORD
fi

KEY_ARGS=()
if [[ -n ${PBS_ENCRYPTION_KEY_FILE-} ]]; then
  KEY_ARGS+=(--keyfile "$PBS_ENCRYPTION_KEY_FILE")
fi

mkdir -p "$TARGET_DIR"
SNAP_PATH="host/$BACKUP_ID/${SNAPSHOT}"

exec "$PBC" restore \
  --repository "$PBS_REPOSITORY" \
  "$SNAP_PATH" \
  home.pxar \
  "$TARGET_DIR" \
  --allow-existing-dirs \
  "${KEY_ARGS[@]}" \
  "$@"
