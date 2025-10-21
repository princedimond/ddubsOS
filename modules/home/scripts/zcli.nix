{
  pkgs,
  profile,
  backupFiles ? [ ".config/mimeapps.list.backup" ],
  ...
}:
let
  backupFilesString = pkgs.lib.strings.concatStringsSep " " backupFiles;
in
pkgs.writeShellScriptBin "zcli" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  # --- Program info ---
  #
  # zcli - NixOS System Management CLI
  # ==================================
  #
  #    Purpose: NixOS system management utility for ddubsOS distribution
  #     Author: Don Williams (ddubs)
  # Start Date: June 7th, 2025
  #    Version: 1.1.0
  #
  # Architecture:
  # - Nix-generated shell script using writeShellScriptBin
  # - Configuration via Nix parameters (profile, backupFiles)
  # - Uses 'nh' tool for NixOS operations, 'inxi' for diagnostics
  # - Git integration for host configuration versioning
  #
  # Helper Functions:
  # verify_hostname()     - Validates current hostname against flake.nix host variable
  #                        Exits with error if mismatch or missing host directory
  # detect_gpu_profile()  - Parses lspci output to identify GPU hardware
  #                        Returns: nvidia/nvidia-laptop/amd/intel/vm/empty
  # handle_backups()      - Removes files listed in BACKUP_FILES array from $HOME
  # print_help()         - Outputs command usage and available operations
  #
  # Command Functions:
  # cleanup              - Interactive cleanup of old generations via 'nh clean'
  # diag                 - Generate system report using 'inxi --full'
  # list-gens           - Display user/system generations via nix-env and nix profile
  # rebuild             - NixOS rebuild using 'nh os switch'
  # rebuild-boot        - NixOS rebuild for next boot using 'nh os boot'
  # trim                - SSD optimization via 'sudo fstrim -v /'
  # update              - Flake update + rebuild using 'nh os switch --update'
  # update-host         - Modify flake.nix host/profile variables via sed
  # doom [sub]          - Doom Emacs management (install/status/remove/update)
  # glances [sub]       - Docker-based Glances server management
  #
  # Variables:
  # PROJECT             - Base directory name (ddubsos/zaneyos)
  # PROFILE             - Hardware profile from Nix parameter
  # BACKUP_FILES        - Array of backup file paths to clean
  # FLAKE_NIX_PATH      - Path to flake.nix for host/profile updates
  #


  # --- Configuration ---
  PROJECT="ddubsos"   #ddubos or zaneyos
  PROFILE="${profile}"
  BACKUP_FILES_STR="${backupFilesString}"
  VERSION="1.1.0"
  FLAKE_NIX_PATH="$HOME/$PROJECT/flake.nix"

  read -r -a BACKUP_FILES <<< "$BACKUP_FILES_STR"

  # --- Pinned tools (available to sourced modules) ---
  GREP="${pkgs.gnugrep}/bin/grep"
  SED="${pkgs.gnused}/bin/sed"
  AWK="${pkgs.gawk}/bin/awk"
  SORT="${pkgs.coreutils}/bin/sort"
  CP="${pkgs.coreutils}/bin/cp"
  DATE="${pkgs.coreutils}/bin/date"
  HOSTNAME_BIN="${pkgs.inetutils}/bin/hostname"
  BASENAME="${pkgs.coreutils}/bin/basename"
  HEAD="${pkgs.coreutils}/bin/head"
  RM="${pkgs.coreutils}/bin/rm"
  LSPCI="${pkgs.pciutils}/bin/lspci"
  IP_BIN="${pkgs.iproute2}/bin/ip"
  INXI_BIN="${pkgs.inxi}/bin/inxi"
  FSTRIM_BIN="${pkgs.util-linux}/bin/fstrim"
  DOCKER_BIN="${pkgs.docker}/bin/docker"
  GIT_BIN="${pkgs.git}/bin/git"

  # Project root used for sourcing modules
  ZROOT_DIR="$HOME/$PROJECT"

  # --- Optional validators module (curated browser/terminal maps) ---
  VALIDATE_LIB="$HOME/$PROJECT/lib/validate.sh"
  if [ -f "$VALIDATE_LIB" ]; then
    # shellcheck disable=SC1090
    . "$VALIDATE_LIB"
  else
    # Minimal fallbacks if the library is missing
    list_browsers() { echo "google-chrome"; }
    list_terminals() { echo "kitty"; }
    # Fallback boolean list used by help and --list-bools if validators lib is missing
    list_bool_attrs() {
      printf "%s\n" \
        gnomeEnable bspwmEnable dwmEnable wayfireEnable cosmicEnable \
        enableEvilhelix enableVscode enableMicro enableAlacritty enableTmux enablePtyxis enableWezterm enableGhostty \
        enableDevEnv sddmWaylandEnable enableOpencode clock24h enableNFS printEnable thunarEnable \
        enableGlances
    }
    browser_supported() { return 1; }
    terminal_supported() { return 1; }
    browser_cmd_for() { :; }
    terminal_cmd_for() { :; }
    is_cmd_available() { command -v "$1" >/dev/null 2>&1; }
  fi

  # --- Libraries: nix helpers and args parser (if available) ---
  NIX_LIB="$HOME/$PROJECT/lib/nix.sh"
  if [ -f "$NIX_LIB" ]; then
    # shellcheck disable=SC1090
    . "$NIX_LIB"
  fi

  ARGS_LIB="$HOME/$PROJECT/lib/args.sh"
  if [ -f "$ARGS_LIB" ]; then
    # shellcheck disable=SC1090
    . "$ARGS_LIB"
  fi

  SYS_LIB="$HOME/$PROJECT/lib/sys.sh"
  if [ -f "$SYS_LIB" ]; then
    # shellcheck disable=SC1090
    . "$SYS_LIB"
  fi

  print_help() {
    echo "ddubsOS CLI Utility -- version $VERSION"
    echo ""
    echo "Usage: zcli [command] [options]"
    echo ""
    echo "Commands:"
    echo "  cleanup         - Clean up old system generations. Can specify a number to keep."
    echo "  diag            - Create a system diagnostic report."
    echo "                    (Filename: homedir/diag.txt)"
    echo "  list-gens       - List user and system generations."
    echo "  hosts-apps      - Display host-specific packages from host-packages.nix."
    echo "  add-host [h p]  - Scaffold hosts/<h> from template; optional GPU profile p."
    echo "  del-host [h]    - Remove hosts/<h> (with confirmation)."
    echo "  rename-host a b - Rename hosts/<a> to hosts/<b> and update flake host if needed."
    echo "  hostname set h  - Set flake 'host' to h (does not move folders)."
    echo "  rebuild         - Rebuild the NixOS system configuration."
    echo "  rebuild-boot    - Rebuild and set as boot default (activates on next restart)."
    echo "  trim            - Trim filesystems to improve SSD performance."
    echo "  update          - Update the flake and rebuild the system."
    echo "  upgrade         - Alias for update."
    echo "  update-host     - Auto set host and profile in flake.nix."
    echo "  stage [--all]   - Interactively stage changes (or stage all) before a rebuild."
    echo ""
    echo "Options for rebuild, rebuild-boot, and update commands:"
    echo "  --dry, -n       - Show what would be done without doing it"
    echo "  --ask, -a       - Ask for confirmation before proceeding"
    echo "  --cores N       - Limit build to N cores (useful for VMs)"
    echo "  --verbose, -v   - Show verbose output"
    echo "  --no-nom        - Don't use nix-output-monitor"
    echo "  --no-stage      - Skip the staging prompt (do not stage anything)"
    echo "  --stage-all     - Stage all untracked/unstaged files automatically before rebuild"
    echo ""
    echo "System Settings (use exact attribute names as in hosts/<host>/variables.nix):"
    echo "  settings                      - Show current host settings (pretty formatted)."
    echo "  settings --list-browsers      - List supported browser keys."
    echo "  settings --list-terminals     - List supported terminal keys."
    echo "  settings set <attr> <value>   - Update an attribute with validation and backup."
    echo "                                  examples: zcli settings set browser firefox"
    echo "                                            zcli settings set gnomeEnable true"
    echo "  settings help                 - Detailed help and examples for settings."
    echo ""
    echo "  help            - Show this help message."
  }





  # --- Settings helpers ---
  SETTINGS_GREEN="$(printf '\033[0;32m')"
  SETTINGS_RED="$(printf '\033[0;31m')"
  SETTINGS_BOLD="$(printf '\033[1m')"
  SETTINGS_RESET="$(printf '\033[0m')"


  # --- Main Logic ---
  if [ "$#" -eq 0 ]; then
    echo "Error: No command provided." >&2
    print_help
    exit 1
  fi

  case "$1" in
    cleanup)
      echo "Warning! This will remove old generations of your system."
      read -p "How many generations to keep (default: all)? " keep_count

      if [ -z "$keep_count" ]; then
        read -p "This will remove all but the current generation. Continue (y/N)? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          nh clean all -v
        else
          echo "Cleanup cancelled."
        fi
      else
        read -p "This will keep the last $keep_count generations. Continue (y/N)? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          nh clean all -k "$keep_count" -v
        else
          echo "Cleanup cancelled."
        fi
      fi

      LOG_DIR="$HOME/zcli-cleanup-logs"
      mkdir -p "$LOG_DIR"
      LOG_FILE="$LOG_DIR/zcli-cleanup-$(date +%Y-%m-%d_%H-%M-%S).log"
      echo "Cleaning up old log files..." >> "$LOG_FILE"
      find "$LOG_DIR" -type f -mtime +3 -name "*.log" -delete >> "$LOG_FILE" 2>&1
      echo "Cleanup process logged to $LOG_FILE"
      ;;
    diag)
      FEATURE_DIAG="$ZROOT_DIR/features/diag.sh"
      if [ -f "$FEATURE_DIAG" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_DIAG"
      else
        echo "Error: feature module not found: $FEATURE_DIAG" >&2
        exit 1
      fi
      if diag_main "$@"; then :; else exit 1; fi
      ;;
    help)
      print_help
      ;;
    settings|features)
      FEATURE_SETTINGS="$ZROOT_DIR/features/settings.sh"
      if [ -f "$FEATURE_SETTINGS" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_SETTINGS"
      else
        echo "Error: feature module not found: $FEATURE_SETTINGS" >&2
        exit 1
      fi
      if settings_main "$@"; then :; else exit 1; fi
      ;;
    list-gens)
      FEATURE_GENS="$ZROOT_DIR/features/generations.sh"
      if [ -f "$FEATURE_GENS" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_GENS"
      else
        echo "Error: feature module not found: $FEATURE_GENS" >&2
        exit 1
      fi
      if generations_main "$@"; then :; else exit 1; fi
      ;;
    hosts-apps)
      FEATURE_HOSTS="$ZROOT_DIR/features/hosts.sh"
      if [ -f "$FEATURE_HOSTS" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_HOSTS"
      else
        echo "Error: feature module not found: $FEATURE_HOSTS" >&2
        exit 1
      fi
      if hosts_apps_main "$@"; then :; else exit 1; fi
      ;;
    rebuild)
      FEATURE_REBUILD="$ZROOT_DIR/features/rebuild.sh"
      if [ -f "$FEATURE_REBUILD" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_REBUILD"
      else
        echo "Error: feature module not found: $FEATURE_REBUILD" >&2
        exit 1
      fi
      if rebuild_main "$@"; then :; else exit 1; fi
      ;;
    rebuild-boot)
      FEATURE_REBUILD="$ZROOT_DIR/features/rebuild.sh"
      if [ -f "$FEATURE_REBUILD" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_REBUILD"
      else
        echo "Error: feature module not found: $FEATURE_REBUILD" >&2
        exit 1
      fi
      if rebuild_main "$@"; then :; else exit 1; fi
      ;;
    trim)
      FEATURE_TRIM="$ZROOT_DIR/features/trim.sh"
      if [ -f "$FEATURE_TRIM" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_TRIM"
      else
        echo "Error: feature module not found: $FEATURE_TRIM" >&2
        exit 1
      fi
      if trim_main "$@"; then :; else exit 1; fi
      ;;
    update|upgrade)
      FEATURE_REBUILD="$ZROOT_DIR/features/rebuild.sh"
      if [ -f "$FEATURE_REBUILD" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_REBUILD"
      else
        echo "Error: feature module not found: $FEATURE_REBUILD" >&2
        exit 1
      fi
      if rebuild_main "$@"; then :; else exit 1; fi
      ;;
    stage)
      FEATURE_REBUILD="$ZROOT_DIR/features/rebuild.sh"
      if [ -f "$FEATURE_REBUILD" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_REBUILD"
      else
        echo "Error: feature module not found: $FEATURE_REBUILD" >&2
        exit 1
      fi
      if stage_main "$@"; then :; else exit 1; fi
      ;;
    update-host)
      target_hostname=""
      target_profile=""

      if [ "$#" -eq 3 ]; then # zcli update-host <hostname> <profile>
        target_hostname="$2"
        target_profile="$3"
      elif [ "$#" -eq 1 ]; then # zcli update-host (auto-detect)
        echo "Attempting to auto-detect hostname and GPU profile..."
        target_hostname=$(hostname)
        target_profile=$(detect_gpu_profile)

        if [ -z "$target_profile" ]; then
          echo "Error: Could not auto-detect a specific GPU profile. Please provide it manually." >&2
          echo "Usage: zcli update-host [hostname] [profile]" >&2
          exit 1
        fi
        echo "Auto-detected Hostname: $target_hostname"
        echo "Auto-detected Profile: $target_profile"
      else
        echo "Error: Invalid number of arguments for 'update-host'." >&2
        echo "Usage: zcli update-host [hostname] [profile]" >&2
        exit 1
      fi

      echo "Updating $FLAKE_NIX_PATH..."

      # Update host
      if sed -i "s/^[[:space:]]*host[[:space:]]*=[[:space:]]*\".*\"/    host = \"$target_hostname\"/" "$FLAKE_NIX_PATH"; then
        echo "Successfully updated host to: $target_hostname"
      else
        echo "Error: Failed to update host in $FLAKE_NIX_PATH" >&2
        exit 1
      fi

      # Update profile
      if sed -i "s/^[[:space:]]*profile[[:space:]]*=[[:space:]]*\".*\"/    profile = \"$target_profile\"/" "$FLAKE_NIX_PATH"; then
        echo "Successfully updated profile to: $target_profile"
      else
        echo "Error: Failed to update profile in $FLAKE_NIX_PATH" >&2
        exit 1
      fi

      echo "Flake.nix updated successfully!"
      ;;
    add-host)
      hostname=""
      profile_arg=""

      if [ "$#" -ge 2 ]; then
        hostname="$2"
      fi
      if [ "$#" -eq 3 ]; then
        profile_arg="$3"
      fi

      if [ -z "$hostname" ]; then
        read -p "Enter the new hostname: " hostname
      fi

      if [ -d "$HOME/$PROJECT/hosts/$hostname" ]; then
        echo "Error: Host '$hostname' already exists." >&2
        exit 1
      fi

      echo "Copying default host configuration..."
      cp -r "$HOME/$PROJECT/hosts/default" "$HOME/$PROJECT/hosts/$hostname"

      detected_profile=""
      if [[ -n "$profile_arg" && "$profile_arg" =~ ^(intel|amd|nvidia|nvidia-laptop|amd-hybrid|vm)$ ]]; then
        detected_profile="$profile_arg"
      else
        echo "Detecting GPU profile..."
        detected_profile=$(detect_gpu_profile)
        echo "Detected GPU profile: $detected_profile"
        read -p "Is this correct? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
          read -p "Enter the correct profile (intel, amd, nvidia, nvidia-laptop, amd-hybrid, vm): " new_profile
          while [[ ! "$new_profile" =~ ^(intel|amd|nvidia|nvidia-laptop|amd-hybrid|vm)$ ]]; do
            echo "Invalid profile. Please enter one of the following: intel, amd, nvidia, nvidia-laptop, amd-hybrid, vm"
            read -p "Enter the correct profile: " new_profile
          done
          detected_profile=$new_profile
        fi
      fi

      echo "Scaffolded host '$hostname'. Suggested profile: '$detected_profile'"
      echo "Tip: set it in flake with: zcli update-host $hostname $detected_profile (or edit flake.nix)"

      read -p "Generate new hardware.nix? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Generating hardware.nix..."
        sudo nixos-generate-config --show-hardware-config > "$HOME/$PROJECT/hosts/$hostname/hardware.nix"
        echo "hardware.nix generated."
      fi

      echo "Adding new host to git..."
      git -C "$HOME/$PROJECT" add .
      echo "hostname: $hostname added"
      ;;
    del-host)
      hostname=""
      if [ "$#" -eq 2 ]; then
        hostname="$2"
      else
        read -p "Enter the hostname to delete: " hostname
      fi

      if [ ! -d "$HOME/$PROJECT/hosts/$hostname" ]; then
        echo "Error: Host '$hostname' does not exist." >&2
        exit 1
      fi

      read -p "Are you sure you want to delete the host '$hostname'? (y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting host '$hostname'..."
        rm -rf "$HOME/$PROJECT/hosts/$hostname"
        git -C "$HOME/$PROJECT" add .
        echo "hostname: $hostname removed"
      else
        echo "Deletion cancelled."
      fi
      ;;

    rename-host)
      if [ "$#" -ne 3 ]; then
        echo "Usage: zcli rename-host <old> <new>" >&2
        exit 1
      fi
      old="$2"; new="$3"
      if [ ! -d "$HOME/$PROJECT/hosts/$old" ]; then
        echo "Error: Host '$old' does not exist." >&2
        exit 1
      fi
      if [ -d "$HOME/$PROJECT/hosts/$new" ]; then
        echo "Error: Target host '$new' already exists." >&2
        exit 1
      fi
      echo "Renaming hosts/$old -> hosts/$new"
      mv "$HOME/$PROJECT/hosts/$old" "$HOME/$PROJECT/hosts/$new"
      git -C "$HOME/$PROJECT" add .
      # If flake host matches old, update it to new
      if $GREP -q "^[[:space:]]*host[[:space:]]*=\s*\"$old\"" "$FLAKE_NIX_PATH"; then
        if $SED -i "s/^[[:space:]]*host[[:space:]]*=\s*\"$old\"/    host = \"$new\"/" "$FLAKE_NIX_PATH"; then
          echo "Updated flake host to '$new'"
        fi
      fi
      echo "Host renamed. Consider rebuilding with: nh os switch -- --flake .#$new"
      ;;

    hostname)
      if [ "$#" -ne 3 ] || [ "$2" != "set" ]; then
        echo "Usage: zcli hostname set <name>" >&2
        exit 1
      fi
      newhost="$3"
      if $SED -i "s/^[[:space:]]*host[[:space:]]*=\s*\".*\"/    host = \"$newhost\"/" "$FLAKE_NIX_PATH"; then
        echo "Flake host set to '$newhost'"
        if [ ! -d "$HOME/$PROJECT/hosts/$newhost" ]; then
          echo "Warning: hosts/$newhost does not exist yet. Create it with: zcli add-host $newhost"
        fi
      else
        echo "Error: Failed to update host in $FLAKE_NIX_PATH" >&2
        exit 1
      fi
      ;;
    glances)
      FEATURE_GLANCES="$ZROOT_DIR/features/glances.sh"
      if [ -f "$FEATURE_GLANCES" ]; then
        # shellcheck disable=SC1090
        . "$FEATURE_GLANCES"
      else
        echo "Error: feature module not found: $FEATURE_GLANCES" >&2
        exit 1
      fi
      if glances_main "$@"; then :; else exit 1; fi
      ;;
    *)
      echo "Error: Invalid command '$1'" >&2
      print_help
      exit 1
      ;;
  esac
''
