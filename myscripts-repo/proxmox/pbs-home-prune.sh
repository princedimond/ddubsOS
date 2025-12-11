#!/usr/bin/env bash
set -euo pipefail

: "${PBS_REPOSITORY:=root@pam@192.168.40.15:8007:PBS-LUN2}"
: "${PBS_FINGERPRINT:=4b:c6:2a:49:62:2e:c6:0d:63:0c:d1:b6:8b:78:be:af:28:2a:94:eb:d4:e7:77:ab:d1:af:c9:ea:c9:07:ef:26}"
DEFAULT_HOSTNAME=$(hostname 2>/dev/null || echo unknown-host)
DEFAULT_USER=${USER:-$(whoami 2>/dev/null || echo user)}
: "${BACKUP_ID:=${DEFAULT_HOSTNAME}-${DEFAULT_USER}-home}"

# Export env expected by proxmox-backup-client
export PBS_REPOSITORY PBS_FINGERPRINT

: "${KEEP_LAST:=7}"
: "${KEEP_DAILY:=14}"
: "${KEEP_WEEKLY:=8}"
: "${KEEP_MONTHLY:=12}"

PBC=${PROXMOX_BACKUP_CLIENT_BIN:-proxmox-backup-client}

if [[ -z ${PBS_PASSWORD-} ]]; then
  read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
  echo
  export PBS_PASSWORD
fi

exec "$PBC" prune \
  "host/$BACKUP_ID" \
  --repository "$PBS_REPOSITORY" \
  --keep-last "$KEEP_LAST" \
  --keep-daily "$KEEP_DAILY" \
  --keep-weekly "$KEEP_WEEKLY" \
  --keep-monthly "$KEEP_MONTHLY" \
  "$@"
