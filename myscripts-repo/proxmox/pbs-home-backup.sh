#!/usr/bin/env bash
set -euo pipefail

# Proxmox Backup Client (PBS) home backup helper for Arch/Linux
# Dependencies: proxmox-backup-client
# Defaults can be overridden via environment variables.

: "${PBS_REPOSITORY:=root@pam@192.168.40.15:8007:PBS-LUN2}"
: "${PBS_FINGERPRINT:=4b:c6:2a:49:62:2e:c6:0d:63:0c:d1:b6:8b:78:be:af:28:2a:94:eb:d4:e7:77:ab:d1:af:c9:ea:c9:07:ef:26}"
DEFAULT_HOSTNAME=$(hostname 2>/dev/null || echo unknown-host)
DEFAULT_USER=${USER:-$(whoami 2>/dev/null || echo user)}
: "${BACKUP_ID:=${DEFAULT_HOSTNAME}-${DEFAULT_USER}-home}"
: "${BACKUP_SOURCE:=$HOME}"

# Export env expected by proxmox-backup-client
export PBS_REPOSITORY PBS_FINGERPRINT

PBC=${PROXMOX_BACKUP_CLIENT_BIN:-proxmox-backup-client}

if ! command -v "$PBC" >/dev/null 2>&1; then
  echo "Error: proxmox-backup-client is not installed or not in PATH" >&2
  exit 127
fi

# Prompt for password/token if not provided. Input is hidden.
if [[ -z ${PBS_PASSWORD-} ]]; then
  read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
  echo
  export PBS_PASSWORD
fi

KEY_ARGS=()
if [[ -n ${PBS_ENCRYPTION_KEY_FILE-} ]]; then
  KEY_ARGS+=(--keyfile "$PBS_ENCRYPTION_KEY_FILE")
fi

# Build exclude args (defaults + optional PBS_EXCLUDE_PATHS, colon-separated)
default_excludes=( "$HOME/pkg" "$HOME/.cache" "$HOME/.local/share/Trash" )
EXCL_ARGS=()
for p in "${default_excludes[@]}"; do
  EXCL_ARGS+=( --exclude "$p" )
done
if [[ -n ${PBS_EXCLUDE_PATHS-} ]]; then
  IFS=':' read -r -a _extra_excludes <<<"$PBS_EXCLUDE_PATHS"
  for p in "${_extra_excludes[@]}"; do
    [[ -n "$p" ]] && EXCL_ARGS+=( --exclude "$p" )
  done
fi

exec "$PBC" backup \
  home.pxar:"$BACKUP_SOURCE" \
  --repository "$PBS_REPOSITORY" \
  --backup-id "$BACKUP_ID" \
  "${EXCL_ARGS[@]}" \
  "${KEY_ARGS[@]}" \
  "$@"
