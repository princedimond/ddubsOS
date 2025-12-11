{
  pkgs,
  config,
  lib,
  username ? "dwilliams",
  ...
}: let
  backupPath = "/home/${username}";
  pbsRepo = "root@pam@192.168.40.15:8007:PBS-LUN2";
  fingerprint = "4b:c6:2a:49:62:2e:c6:0d:63:0c:d1:b6:8b:78:be:af:28:2a:94:eb:d4:e7:77:ab:d1:af:c9:ea:c9:07:ef:26";
  backupId = "${config.networking.hostName}-${username}-home";

  backupScript = pkgs.writeShellScriptBin "pbs-home-backup" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    # Prompt for password/token if not provided. Input is hidden.
    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi

    KEY_ARGS=()
    if [[ -n ''${PBS_ENCRYPTION_KEY_FILE-} ]]; then
      KEY_ARGS+=(--keyfile "$PBS_ENCRYPTION_KEY_FILE")
    fi

    # Build exclude args (defaults + optional PBS_EXCLUDE_PATHS, colon-separated)
    default_excludes=( "$HOME/pkg" "$HOME/.cache" "$HOME/.local/share/Trash" )
    EXCL_ARGS=()
    for p in "''${default_excludes[@]}"; do
      EXCL_ARGS+=( --exclude "$p" )
    done
    if [[ -n ''${PBS_EXCLUDE_PATHS-} ]]; then
      IFS=':' read -r -a _extra_excludes <<<"$PBS_EXCLUDE_PATHS"
      for p in "''${_extra_excludes[@]}"; do
        [[ -n "$p" ]] && EXCL_ARGS+=( --exclude "$p" )
      done
    fi

    exec ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client backup \
      home.pxar:"${backupPath}" \
      --repository "$PBS_REPOSITORY" \
      --backup-id "$BACKUP_ID" \
      ''${EXCL_ARGS[@]} \
      ''${KEY_ARGS[@]} \
      "$@"
  '';

  listScript = pkgs.writeShellScriptBin "pbs-home-ls" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi


    # List snapshots for the backup group host/<backup-id>
    out="$(${pkgs.proxmox-backup-client}/bin/proxmox-backup-client snapshot list \
      "host/$BACKUP_ID" \
      --repository "$PBS_REPOSITORY" \
      --output-format text \
      "$@" || true)"

    if [[ -z "$out" ]]; then
      echo "No snapshots found for host/$BACKUP_ID"
      exit 0
    fi

    printf '%s\n' "$out"
  '';

  restoreScript = pkgs.writeShellScriptBin "pbs-home-restore" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    # Usage and args
    if [[ $# -lt 1 ]]; then
      echo "Usage: pbs-home-restore <SNAPSHOT> [TARGET_DIR] [-- additional proxmox args]" >&2
      echo "Example snapshot format: 2025-09-24T02:10:45Z" >&2
      echo "If TARGET_DIR is omitted, defaults to $HOME/restore-<SNAPSHOT>" >&2
      exit 1
    fi

    SNAPSHOT="$1"; shift || true
    TARGET_DIR="''${1:-"$HOME/restore-''${SNAPSHOT}"}"
    if [[ $# -ge 1 ]]; then shift; fi

    # Prompt for password/token if not provided. Input is hidden.
    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi

    KEY_ARGS=()
    if [[ -n ''${PBS_ENCRYPTION_KEY_FILE-} ]]; then
      KEY_ARGS+=(--keyfile "$PBS_ENCRYPTION_KEY_FILE")
    fi

    mkdir -p "$TARGET_DIR"

    # Snapshot path format: host/<backup-id>/<snapshot>
    SNAP_PATH="host/$BACKUP_ID/''${SNAPSHOT}"

    exec ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client restore \
      --repository "$PBS_REPOSITORY" \
      "$SNAP_PATH" \
      home.pxar \
      "$TARGET_DIR" \
      --allow-existing-dirs \
      ''${KEY_ARGS[@]} \
      "$@"
  '';

  lastScript = pkgs.writeShellScriptBin "pbs-home-last" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    # Prompt for password/token if not provided.
    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi

    out="$(${pkgs.proxmox-backup-client}/bin/proxmox-backup-client snapshot list \
      "host/$BACKUP_ID" \
      --repository "$PBS_REPOSITORY" \
      --output-format text \
      "$@" || true)"

    # Extract snapshot paths like host/<group>/<timestamp>
    last_path="$(printf '%s\n' "$out" | grep -o 'host/[^ ]*' | tail -n 1 || true)"
    if [[ -z "$last_path" ]]; then
      echo "No snapshots found for host/$BACKUP_ID" >&2
      exit 1
    fi
    snap_ts="''${last_path##*/}"

    printf '%s\n' "$snap_ts"
  '';

  restoreLastScript = pkgs.writeShellScriptBin "pbs-home-restore-last" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    # Prompt for password/token if not provided.
    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi

    # Get latest snapshot path and derive timestamp
    out="$(${pkgs.proxmox-backup-client}/bin/proxmox-backup-client snapshot list \
      "host/$BACKUP_ID" \
      --repository "$PBS_REPOSITORY" \
      --output-format text \
      "$@" || true)"

    last_path="$(printf '%s\n' "$out" | grep -o 'host/[^ ]*' | tail -n 1 || true)"
    if [[ -z "$last_path" ]]; then
      echo "No snapshots found for host/$BACKUP_ID" >&2
      exit 1
    fi
    SNAPSHOT="''${last_path##*/}"

    TARGET_DIR="''${1:-"$HOME/restore-''${SNAPSHOT}"}"
    if [[ $# -ge 1 ]]; then shift; fi

    KEY_ARGS=()
    if [[ -n ''${PBS_ENCRYPTION_KEY_FILE-} ]]; then
      KEY_ARGS+=(--keyfile "$PBS_ENCRYPTION_KEY_FILE")
    fi

    mkdir -p "$TARGET_DIR"

    SNAP_PATH="host/$BACKUP_ID/''${SNAPSHOT}"

    exec ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client restore \
      --repository "$PBS_REPOSITORY" \
      "$SNAP_PATH" \
      home.pxar \
      "$TARGET_DIR" \
      --allow-existing-dirs \
      ''${KEY_ARGS[@]} \
      "$@"
  '';

  pruneScript = pkgs.writeShellScriptBin "pbs-home-prune" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    # Prompt for password/token if not provided.
    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi

    KEEP_LAST="''${KEEP_LAST:-7}"
    KEEP_DAILY="''${KEEP_DAILY:-14}"
    KEEP_WEEKLY="''${KEEP_WEEKLY:-8}"
    KEEP_MONTHLY="''${KEEP_MONTHLY:-12}"

    exec ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client prune \
      "host/$BACKUP_ID" \
      --repository "$PBS_REPOSITORY" \
      --keep-last "$KEEP_LAST" \
      --keep-daily "$KEEP_DAILY" \
      --keep-weekly "$KEEP_WEEKLY" \
      --keep-monthly "$KEEP_MONTHLY" \
      "$@"
  '';

  verifyScript = pkgs.writeShellScriptBin "pbs-home-verify" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Allow overriding via env; fall back to module defaults
        export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
        export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
        BACKUP_ID="''${BACKUP_ID:-${backupId}}"

        if [[ "''${1-}" == "-h" || "''${1-}" == "--help" ]]; then
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

        MODE="''${1:-latest}"
        if [[ $# -ge 1 ]]; then shift; fi

        # Prompt for password/token if not provided. Input is hidden.
        if [[ -z ''${PBS_PASSWORD-} ]]; then
          read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
          echo
          export PBS_PASSWORD
        fi

        out="$(${pkgs.proxmox-backup-client}/bin/proxmox-backup-client snapshot list \
          "host/$BACKUP_ID" \
          --repository "$PBS_REPOSITORY" \
          --output-format text \
          "$@" || true)"

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
          SNAPSHOT="''${last_path##*/}"
          echo "Verifying (catalog read) host/$BACKUP_ID/''${SNAPSHOT}..."
    exec ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client \
    snapshot files "host/$BACKUP_ID/''${SNAPSHOT}" \
            --repository "$PBS_REPOSITORY"
        else
          rc=0
          # Verify all snapshots in this group (catalog read)
          printf '%s\n' "$out" | grep -o 'host/[^ ]*' | while IFS= read -r p; do
            snap_id="''${p##*/}"
            [[ -z "$snap_id" ]] && continue
            echo "Verifying (catalog read) host/$BACKUP_ID/''${snap_id}..."
    if ! ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client \
    snapshot files "host/$BACKUP_ID/''${snap_id}" \
              --repository "$PBS_REPOSITORY"; then
              echo "Failed to verify catalog for host/$BACKUP_ID/''${snap_id}" >&2
              rc=1
            fi
          done
          exit "$rc"
        fi
  '';

  lsAllScript = pkgs.writeShellScriptBin "pbs-home-ls-all" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"

    if [[ -z ''${PBS_PASSWORD-} ]]; then
      read -rs -p "PBS password or API token secret for root@pam: " PBS_PASSWORD
      echo
      export PBS_PASSWORD
    fi

    out="$(${pkgs.proxmox-backup-client}/bin/proxmox-backup-client snapshot list \
      --repository "$PBS_REPOSITORY" \
      --output-format text \
      "$@" || true)"

    if [[ -z "$out" ]]; then
      echo "No snapshots found in repository $PBS_REPOSITORY"
      exit 0
    fi

    printf '%s\n' "$out"
  '';

  showScript = pkgs.writeShellScriptBin "pbs-home-show" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Allow overriding via env; fall back to module defaults
    export PBS_REPOSITORY="''${PBS_REPOSITORY:-${pbsRepo}}"
    export PBS_FINGERPRINT="''${PBS_FINGERPRINT:-${fingerprint}}"
    BACKUP_ID="''${BACKUP_ID:-${backupId}}"

    echo "Repository: $PBS_REPOSITORY"
    echo "Fingerprint: $PBS_FINGERPRINT"
    echo "Backup ID: $BACKUP_ID"
    echo "Source: ${backupPath}"
  '';
in {
  options = {};

  config = {
    environment.systemPackages = [
      pkgs.proxmox-backup-client
      backupScript
      listScript
      restoreScript
      lastScript
      restoreLastScript
      lsAllScript
      showScript
      pruneScript
      verifyScript
    ];
  };
}
