#!/usr/bin/env bash
set -euo pipefail

: "${PBS_REPOSITORY:=root@pam@192.168.40.15:8007:PBS-LUN2}"
: "${PBS_FINGERPRINT:=4b:c6:2a:49:62:2e:c6:0d:63:0c:d1:b6:8b:78:be:af:28:2a:94:eb:d4:e7:77:ab:d1:af:c9:ea:c9:07:ef:26}"
DEFAULT_HOSTNAME=$(hostname 2>/dev/null || echo unknown-host)
DEFAULT_USER=${USER:-$(whoami 2>/dev/null || echo user)}
: "${BACKUP_ID:=${DEFAULT_HOSTNAME}-${DEFAULT_USER}-home}"

# Export env expected by proxmox-backup-client
export PBS_REPOSITORY PBS_FINGERPRINT

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
  cat <<EOF
Usage: $(basename "$0") [latest|all]

Performs a lightweight client-side verification by reading the snapshot catalog
(via 'proxmox-backup-client snapshot files'). For full data re-verification use
server-side tools on the PBS host.

Examples:
  $(basename "$0")            # verify latest snapshot (default)
  $(basename "$0") all        # verify all snapshots in the group
EOF
  exit 0
fi

MODE="${1:-latest}"
if [[ $# -ge 1 ]]; then shift; fi

PBC=${PROXMOX_BACKUP_CLIENT_BIN:-proxmox-backup-client}

if [[ -z ${PBS_PASSWORD-} ]]; then
  read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
  echo
  export PBS_PASSWORD
fi

out="$($PBC snapshot list "host/$BACKUP_ID" --repository "$PBS_REPOSITORY" --output-format text "$@" || true)"
if [[ -z "$out" ]]; then
  echo "No snapshots found for host/$BACKUP_ID" >&2
  exit 1
fi

if [[ "$MODE" == "latest" ]]; then
  last_path="$(printf '%s\n' "$out" | grep -o 'host/[^ ]*' | tail -n 1 || true)"
  if [[ -z "$last_path" ]]; then
    echo "Could not determine latest snapshot id" >&2
    exit 1
  fi
  SNAPSHOT="${last_path##*/}"
  echo "Verifying (catalog read) host/$BACKUP_ID/${SNAPSHOT}..."
  # Read the catalog of the home.pxar archive; exit status indicates accessibility
exec "$PBC" snapshot files "host/$BACKUP_ID/${SNAPSHOT}" --repository "$PBS_REPOSITORY"
else
  rc=0
  printf '%s\n' "$out" | grep -o 'host/[^ ]*' | while IFS= read -r p; do
    snap_id="${p##*/}"
    [[ -z "$snap_id" ]] && continue
    echo "Verifying (catalog read) host/$BACKUP_ID/${snap_id}..."
if ! "$PBC" snapshot files "host/$BACKUP_ID/${snap_id}" --repository "$PBS_REPOSITORY"; then
      echo "Failed to verify catalog for host/$BACKUP_ID/${snap_id}" >&2
      rc=1
    fi
  done
  exit "$rc"
fi
