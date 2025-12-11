# Proxmox Backup Client helper scripts (Arch/Linux)

These scripts mirror the ddubsOS Nix module `proxmox-backup-client.nix` but run as plain Bash on Arch/Linux.

Requirements:
- proxmox-backup-client (install via your package manager or AUR)

Defaults (override via env):
- PBS_REPOSITORY (default: root@pam@192.168.40.15:8007:PBS-LUN2)
- PBS_FINGERPRINT (default set from repo)
- BACKUP_ID (default: "$(hostname)-$USER-home")
- PBS_ENCRYPTION_KEY_FILE (optional path to key)
- PBS_PASSWORD (will be prompted if not set)
- BACKUP_SOURCE for backup (default: $HOME)
- Default excludes (pbs-home-backup.sh): $HOME/pkg, $HOME/.cache, $HOME/.local/share/Trash
- PBS_EXCLUDE_PATHS: optional colon-separated extra paths to exclude (e.g., "$HOME/.npm:$HOME/.cargo/registry")

Scripts:
- pbs-home-show.sh           # Show effective config
- pbs-home-backup.sh         # Create home backup
- pbs-home-ls.sh             # List snapshots for BACKUP_ID
- pbs-home-last.sh           # Print latest snapshot timestamp for BACKUP_ID
- pbs-home-restore.sh        # Restore specific snapshot to target dir
- pbs-home-restore-last.sh   # Restore latest snapshot to target dir
- pbs-home-prune.sh          # Prune retention (KEEP_* envs)
- pbs-home-verify.sh         # Verify latest or all snapshots (catalog read via 'snapshot files')
- pbs-home-ls-all.sh         # List all snapshots in repository

Security: do not hardcode secrets in files. Supply PBS_PASSWORD at runtime or via your secret manager.
