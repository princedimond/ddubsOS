#!/usr/bin/env bash
set -Eeuo pipefail

# Fedora install of common apps and configuration
# - Adds error checking and logging
# - Handles /mnt/nas mount and config copying
# - Options: --copy-only, --dry-run, --help

# ---------- Config ----------
NAS_MOUNT="/mnt/nas"
NAS_CONFIG_DIR="$NAS_MOUNT/config.files"
DRY_RUN=0
COPY_ONLY=0
FONTS_ONLY=0
SKIP_ALL=0
FEDVER=$(rpm -E %fedora 2>/dev/null || echo "")
ARCH=$(uname -m 2>/dev/null || echo "")

# ---------- COPR state ----------
# Track which COPR slugs are supported for this system
# and enabled (or not needed)
declare -A COPR_OK

# Map packages to their COPR slug
declare -A PKG_TO_COPR=(
  [eza]=alternateved/eza
  [yazi]=varlad/yazi
  [ghostty]=alternateved/ghostty
  [lazygit]=sirtony/lazygit
  [starship]=atim/starship
  [niri]=yalter/niri
  [zellij]=varlad/zellij
  [dms]=avengemedia/dms
  [gping]=atim/gping
  [wezterm]=wezfurlong/wezterm-nightly
)

# ---------- Colors & icons ----------
RESET="\033[0m"; BOLD="\033[1m"
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"; CYAN="\033[36m"; GRAY="\033[90m"
ICON_INFO="ℹ️"; ICON_OK="✅"; ICON_WARN="⚠️"; ICON_ERR="❌"; ICON_STEP="▶️"

info()   { printf "%b%s%b %b%s%b\n"   "$BLUE" "$ICON_INFO" "$RESET"  "$BOLD" "$*" "$RESET"; }
success(){ printf "%b%s%b %s\n" "$GREEN" "$ICON_OK" "$RESET" "$*"; }
warn()   { printf "%b%s%b %s\n" "$YELLOW" "$ICON_WARN" "$RESET" "$*"; }
error()  { printf "%b%s%b %s\n" "$RED" "$ICON_ERR" "$RESET" "$*" 1>&2; }
step()   { printf "%b%s%b %s\n" "$CYAN" "$ICON_STEP" "$RESET" "$*"; }

run() {
  if (( DRY_RUN )); then
    printf "%b+ %s%b\n" "$GRAY" "$(printf '%q ' "$@")" "$RESET"
  else
    "$@"
  fi
}

usage() {
  cat <<'USAGE'
Usage: fedora-copr.sh [options]

Options:
  -c, --copy-only   Only copy config files from /mnt/nas (no installs)
  -f, --fonts-only  Only ensure DMS fonts (skip other installs)
      --dry-run     Show what would be done without making changes
  -h, --help        Show this help
USAGE
}

# ---------- Arg parsing ----------
while [[ $# -gt 0 ]]; do
  case "${1}" in
    -c|--copy-only) COPY_ONLY=1; shift ;;
    -f|--fonts-only) FONTS_ONLY=1; shift ;;
    --dry-run)      DRY_RUN=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    *) error "Unknown option: $1"; usage; exit 2 ;;
  esac
done

confirm() {
  # confirm "Message" [default_yes]
  local msg=${1:-"Are you sure?"}
  local def=${2:-"y"}
  local prompt="[y/N]"; [[ "$def" =~ ^[Yy]$ ]] && prompt="[Y/n]"
  local reply
  read -r -p "$msg $prompt " reply || true
  reply=${reply:-$def}
  [[ "$reply" =~ ^[Yy]$ ]]
}

ask_backup_or_skip() {
  # ask_backup_or_skip "path"
  local path="$1"
  local reply

  # Respect global Skip-All
  if (( SKIP_ALL )); then
    warn "Skip-All enabled; skipping '$path'"
    return 1
  fi

  while true; do
    read -r -p "'$path' exists. (B)ackup, (S)kip, Skip (A)ll? [B/s/a] " reply || reply="B"
    reply=${reply:-B}
    case "${reply}" in
      B|b) return 0 ;;
      S|s) return 1 ;;
      A|a) SKIP_ALL=1; warn "Skip-All enabled; skipping '$path' and all subsequent conflicts"; return 1 ;;
      *) printf "Please answer B, S, or A.\n" ;;
    esac
  done
}

ensure_nas_available() {
  if [[ -d "$NAS_CONFIG_DIR" ]]; then
    return 0
  fi

  if mountpoint -q "$NAS_MOUNT"; then
    if [[ -d "$NAS_CONFIG_DIR" ]]; then
      return 0
    fi
    warn "$NAS_MOUNT is mounted but $NAS_CONFIG_DIR not found"
  else
    if grep -Eq '^[^#].*\s/mnt/nas\s' /etc/fstab; then
      step "Attempting to mount $NAS_MOUNT from /etc/fstab"
      if run sudo mount "$NAS_MOUNT"; then
        if [[ -d "$NAS_CONFIG_DIR" ]]; then
          return 0
        else
          warn "Mounted $NAS_MOUNT but $NAS_CONFIG_DIR not found"
        fi
      else
        warn "Failed to mount $NAS_MOUNT"
      fi
    else
      warn "$NAS_MOUNT not mounted and no /etc/fstab entry found"
    fi
  fi
  return 1
}

ensure_rc_sources() {
  # Ensure ~/.bashrc sources ~/.bashrc-personal and ~/.zshrc sources ~/.zshrc-personal
  local bashrc="$HOME/.bashrc" bashrc_personal="$HOME/.bashrc-personal"
  local zshrc="$HOME/.zshrc" zshrc_personal="$HOME/.zshrc-personal"

  if [[ -f "$bashrc_personal" ]]; then
    # shellcheck disable=SC2016
    local line_bash='[ -f "$HOME/.bashrc-personal" ] && source "$HOME/.bashrc-personal"'
    if ! grep -Fq ".bashrc-personal" "$bashrc" 2>/dev/null; then
      step "Adding source of .bashrc-personal to $bashrc"
      if (( DRY_RUN )); then
        printf "Would append to %s: %s\n" "$bashrc" "$line_bash"
      else
        mkdir -p "$(dirname "$bashrc")"
        printf "%s\n" "$line_bash" >> "$bashrc"
      fi
    else
      info "$bashrc already sources .bashrc-personal"
    fi
  else
    info "No $bashrc_personal found to source"
  fi

  if [[ -f "$zshrc_personal" ]]; then
    # shellcheck disable=SC2016
    local line_zsh='[ -f "$HOME/.zshrc-personal" ] && source "$HOME/.zshrc-personal"'
    if ! grep -Fq ".zshrc-personal" "$zshrc" 2>/dev/null; then
      step "Adding source of .zshrc-personal to $zshrc"
      if (( DRY_RUN )); then
        printf "Would append to %s: %s\n" "$zshrc" "$line_zsh"
      else
        mkdir -p "$(dirname "$zshrc")"
        printf "%s\n" "$line_zsh" >> "$zshrc"
      fi
    else
      info "$zshrc already sources .zshrc-personal"
    fi
  else
    info "No $zshrc_personal found to source"
  fi
}

backup_then_copy_file() {
  # backup_then_copy_file src dest
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    if ask_backup_or_skip "$dest"; then
      local ts
      ts=$(date +%Y%m%d-%H%M%S)
      local backup="${dest}.bak.${ts}"
      step "Backing up $dest -> $backup"
      run mv -v "$dest" "$backup"
    else
      warn "Skipped $dest"
      return 0
    fi
  fi
  run cp -v "$src" "$dest"
}

backup_then_copy_dir() {
  # backup_then_copy_dir src_dir dest_dir
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    if ask_backup_or_skip "$dest"; then
      local ts
      ts=$(date +%Y%m%d-%H%M%S)
      local backup="${dest}.bak.${ts}"
      step "Backing up $dest -> $backup"
      run mv -v "$dest" "$backup"
    else
      warn "Skipped $dest"
      return 0
    fi
  fi
  run cp -rv "$src" "$dest"
}

copy_config_files() {
  if ! ensure_nas_available; then
    if confirm "Could not access $NAS_CONFIG_DIR. Continue without copying standard config files?" y; then
      warn "Skipping config copy"
      return 0
    else
      error "Aborting per user decision"
      return 1
    fi
  fi

  step "Copying configuration files from $NAS_CONFIG_DIR"

  run mkdir -p "$HOME/.config/niri"
  backup_then_copy_file "$NAS_CONFIG_DIR/OS/Fedora/fedora.niri.config.kdl" "$HOME/.config/niri/fedora.niri.config.kdl"

  run mkdir -p "$HOME/.config"
  backup_then_copy_file "$NAS_CONFIG_DIR/Shells/starship/garuda-mokka.starship.toml" "$HOME/.config/starship.toml"

  run mkdir -p "$HOME/.config/ghostty"
  backup_then_copy_file "$NAS_CONFIG_DIR/skel/ghostty.config.xerolinux" "$HOME/.config/ghostty/config"

  backup_then_copy_dir "$NAS_CONFIG_DIR/yazi" "$HOME/.config/yazi"
  run mkdir -p "$HOME/.config/tmux"
  backup_then_copy_dir "$NAS_CONFIG_DIR/skel/tmux/tmux.no.git.folders" "$HOME/.config/tmux"

  # Personal shells
  if [[ -f "$NAS_CONFIG_DIR/.bashrc-personal" ]]; then
    backup_then_copy_file "$NAS_CONFIG_DIR/.bashrc-personal" "$HOME/.bashrc-personal"
  fi
  if [[ -f "$NAS_CONFIG_DIR/.zshrc-personal" ]]; then
    backup_then_copy_file "$NAS_CONFIG_DIR/.zshrc-personal" "$HOME/.zshrc-personal"
  fi

  ensure_rc_sources
  success "Config copy complete"
}

# ---------- COPR helpers ----------
copr_repo_file() {
  # Map slug owner/project -> repo file path
  local slug="$1"
  local owner="${slug%%/*}"
  local proj="${slug##*/}"
  printf '/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:%s:%s.repo' "$owner" "$proj"
}

copr_enabled() {
  local slug="$1" f
  f="$(copr_repo_file "$slug")"
  [[ -f "$f" ]] && grep -qE '^enabled=1' "$f"
}

copr_supports_current() {
  local slug="$1"
  if [[ -z "$FEDVER" || -z "$ARCH" ]]; then
    return 1
  fi
  # Use dnf to check available chroots
  dnf -q copr info "$slug" 2>/dev/null | grep -q "fedora-${FEDVER}-${ARCH}"
}

enable_copr_if_needed() {
  local slug="$1"

  if copr_supports_current "$slug"; then
    # Supported on this Fedora/arch
    if copr_enabled "$slug"; then
      info "COPR $slug already enabled"
      COPR_OK["$slug"]=1
      return 0
    fi
    step "Enabling COPR $slug (supports fedora-$FEDVER-$ARCH)"
    if run sudo dnf copr enable "$slug" -y; then
      COPR_OK["$slug"]=1
      return 0
    else
      warn "Failed to enable COPR $slug"
      COPR_OK["$slug"]=0
      return 1
    fi
  else
    warn "COPR $slug does not declare support for fedora-$FEDVER-$ARCH; skipping"
    COPR_OK["$slug"]=0
    return 0
  fi
}

install_packages() {
  step "Enabling COPR repos"
  local COPRS=(
    atim/starship
    varlad/yazi
    alternateved/eza
    sirtony/lazygit
    alternateved/ghostty
    yalter/niri
    varlad/zellij
    avengemedia/dms
    atim/gping
    wezfurlong/wezterm-nightly
  )
  local slug
  for slug in "${COPRS[@]}"; do
    enable_copr_if_needed "$slug"
  done

  step "Installing COPR-based apps"
  # Build install list only for packages whose COPR is supported/enabled
  local INSTALL_PKGS=()
  local pkg slug
  for pkg in eza yazi ghostty lazygit starship niri zellij dms gping wezterm; do
    slug=${PKG_TO_COPR[$pkg]:-}
    if [[ -z "$slug" || ${COPR_OK[$slug]:-0} -eq 1 ]]; then
      INSTALL_PKGS+=("$pkg")
    else
      warn "Skipping install of $pkg (COPR $slug unsupported)"
    fi
  done
  if (( ${#INSTALL_PKGS[@]} > 0 )); then
    run sudo dnf install -y --skip-unavailable "${INSTALL_PKGS[@]}"
  else
    info "No COPR-based apps to install for this system"
  fi

  step "Installing standard packages"
  run sudo dnf install -y git wget curl ncdu bat ripgrep luarocks ugrep htop btop flatpak distrobox
  run sudo dnf install -y zoxide tmux rsync variety feh swww virt-viewer nvtop warp-terminal mtr kitty

  step "Configuring Flatpak"
  run sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  step "Installing Flatpak apps (from flathub)"
  run flatpak install -y flathub com.github.tchx84.Flatseal com.visualstudio.code io.github.dvlv.boxbuddyrs io.github.flattool.Warehouse

  step "Installing Docker"
  run sudo dnf -y install dnf-plugins-core
  # shellcheck disable=SC2016
  if (( DRY_RUN )); then
    printf "Would write /etc/yum.repos.d/docker-ce.repo with Docker repo config\n"
  else
    sudo tee /etc/yum.repos.d/docker-ce.repo >/dev/null <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/fedora/42/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
  fi
  run sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  run sudo usermod -aG docker "$USER"
  run sudo systemctl enable --now docker

  success "Package installation complete"
}

ensure_dms_fonts() {
  step "Ensuring fonts required by Dank Material Shell (DMS)"

  # Ensure system fonts directory exists
  run sudo install -d -m 0755 /usr/share/fonts

  local changed=0
  local IFS='|'
  local font
  # Fields: Label|URL|Destination|fc-list check term
  local FONTS=(
    "Material Symbols Rounded|https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf|/usr/share/fonts/MaterialSymbolsRounded.ttf|Material Symbols Rounded"
    "Inter Variable|https://github.com/rsms/inter/raw/refs/tags/v4.1/docs/font-files/InterVariable.ttf|/usr/share/fonts/InterVariable.ttf|Inter"
    "Fira Code|https://github.com/tonsky/FiraCode/releases/latest/download/FiraCode-Regular.ttf|/usr/share/fonts/FiraCode-Regular.ttf|Fira Code"
  )

  for font in "${FONTS[@]}"; do
    # shellcheck disable=SC2162
    read -r LABEL URL DEST CHECK <<< "$font"

    if fc-list | grep -qi -- "$CHECK"; then
      info "Font '$LABEL' already available"
      continue
    fi

    if [[ -f "$DEST" ]]; then
      info "Font file for '$LABEL' already present at $DEST"
      continue
    fi

    step "Downloading font: $LABEL"
    if run sudo curl -fL "$URL" -o "$DEST"; then
      changed=1
    else
      warn "Failed to download $LABEL from $URL"
    fi
  done

  if (( changed )); then
    step "Rebuilding font cache"
    run sudo fc-cache -fv
  else
    info "No font changes needed"
  fi
}

main() {
  info "Starting Fedora setup"

  if confirm "Strongly recommended: run 'sudo dnf upgrade --refresh' now to update metadata and upgrade before installs?" y; then
    step "Upgrading system (dnf upgrade --refresh)"
    run sudo dnf upgrade --refresh -y
  else
    warn "Proceeding without dnf upgrade --refresh"
  fi

  if (( FONTS_ONLY )); then
    info "Fonts-only mode"
    ensure_dms_fonts
    success "Fonts installed"
    return 0
  fi

  if (( COPY_ONLY )); then
    info "Copy-only mode"
    copy_config_files
    success "Done"
    return 0
  fi

  install_packages
  ensure_dms_fonts
  copy_config_files
  success "All tasks complete"
}

main "$@"
