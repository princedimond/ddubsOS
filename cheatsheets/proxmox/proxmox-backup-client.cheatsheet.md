# Proxmox Backup Client quick reference (ddubsOS helpers)

Environment variables

- PBS_REPOSITORY: user@realm@host:port:datastore (example: root@pam@192.168.40.15:8007:PBS-LUN2)
- PBS_FINGERPRINT: TLS SHA-256 fingerprint (verify it before first use)
- BACKUP_ID: backup group id (default: "$(hostname)-$USER-home")
- PBS_ENCRYPTION_KEY_FILE: optional client-side key (pxar encryption)
- PBS_PASSWORD: password or API token secret (prompted if unset)

Common tasks

- Show effective config
  pbs-home-show

- Backup home (pxar) with sensible excludes
  pbs-home-backup \
    --exclude "$HOME/.cache/**" \
    --exclude "$HOME/.local/share/Trash/**"
  # Extra excludes via env: PBS_EXCLUDE_PATHS="$HOME/.npm:$HOME/.cargo/registry"

- List snapshots for your group
  pbs-home-ls
  # JSON pretty: pbs-home-ls --output-format json-pretty

- Latest snapshot timestamp
  pbs-home-last

- Restore latest snapshot
  pbs-home-restore-last "$HOME/restore-latest"
  # Omit target dir to restore to ~/restore-<SNAPSHOT>

- Restore specific snapshot to a directory
  pbs-home-restore 2025-09-24T02:10:45Z "$HOME/restore"

- Restore a single file (raw client)
  proxmox-backup-client restore \
    --repository "$PBS_REPOSITORY" \
    host/$BACKUP_ID/2025-09-24T02:10:45Z \
    home.pxar "$HOME/restore" \
    --allow-existing-dirs \
    --include 'Documents/important.pdf'

- Prune retention (defaults)
  # KEEP_LAST=7 KEEP_DAILY=14 KEEP_WEEKLY=8 KEEP_MONTHLY=12
  pbs-home-prune
  # Customize: KEEP_LAST=10 KEEP_DAILY=30 pbs-home-prune

- Verify backups (catalog read)
  pbs-home-verify        # latest
  pbs-home-verify all    # all snapshots

TLS fingerprint check

openssl s_client -connect 192.168.40.15:8007 -servername 192.168.40.15 </dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256

Secrets and automation

- Use a 600-permission env file for systemd or a secret manager (sops-nix/agenix)
- For API tokens: set PBS_REPOSITORY to user@realm!TOKEN@host:port:datastore; set PBS_PASSWORD to the token secret
