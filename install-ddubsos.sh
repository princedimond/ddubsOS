#!/usr/bin/env bash

######################################
# Install script for ddubsos  
# Author:  Don Williams 
# Date: July 7, 2025
#######################################

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="$(dirname "$0")"
LOG_FILE="${LOG_DIR}/install_$(date +"%Y-%m-%d_%H-%M-%S").log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to print a section header
print_header() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║ ${1} ${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print an error message
print_error() {
  echo -e "${RED}Error: ${1}${NC}"
}

# Function to print a success banner
print_success_banner() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                 ddubsOS Installation Successful!                      ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}║   Please reboot your system for changes to take full effect.          ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print a failure banner
print_failure_banner() {
  echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                 ddubsOS Installation Failed!                          ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║   Please review the log file for details:                             ║${NC}"
  echo -e "${RED}║   ${LOG_FILE}                                                        ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Optional flags and parameters
REGEN_HW=0
BRANCH="Stable-v2.5.8"
REPO_URL=""
REPO_URL_GH="https://github.com/dwilliam62/ddubsos.git"
REPO_URL_GL="https://gitlab.com/dwilliam62/ddubsos.git"
FORCE_GITLAB=0
# New flags
HOST_CLI=""
PROFILE_CLI=""
BUILD_HOST=0
NONINTERACTIVE=0

print_usage() {
  cat <<EOF
Usage: $0 [--regen-hw] [--branch BRANCH] [--repo URL] [--use-gitlab] [--host NAME] [--profile NAME] [--build-host] [--non-interactive]

Options:
  --regen-hw         Regenerate hardware.nix using nixos-generate-config on this system
  --branch BRANCH    Branch to checkout after cloning (default: main)
  --repo URL         Explicit repository URL to clone (overrides defaults)
  --use-gitlab       Prefer GitLab URL by default (fallback to GitHub)
  --host NAME        Hostname to configure (skips prompt)
  --profile NAME     GPU profile: amd|intel|nvidia|nvidia-laptop|vm (skips detection/prompt)
  --build-host       Build flake target by host (.#<host>) instead of profile (default)
  --non-interactive  Do not prompt; accept defaults and proceed automatically
EOF
}

# Argument parsing (supports --arg=value and --arg value)
while [ $# -gt 0 ]; do
  case "$1" in
    --regen-hw)
      REGEN_HW=1
      shift
      ;;
    --branch)
      BRANCH="$2"; shift 2
      ;;
    --branch=*)
      BRANCH="${1#*=}"; shift 1
      ;;
    --repo)
      REPO_URL="$2"; shift 2
      ;;
    --repo=*)
      REPO_URL="${1#*=}"; shift 1
      ;;
    --use-gitlab)
      FORCE_GITLAB=1; shift 1
      ;;
    --host)
      HOST_CLI="$2"; shift 2
      ;;
    --host=*)
      HOST_CLI="${1#*=}"; shift 1
      ;;
    --profile)
      PROFILE_CLI="$2"; shift 2
      ;;
    --profile=*)
      PROFILE_CLI="${1#*=}"; shift 1
      ;;
    --build-host)
      BUILD_HOST=1; shift 1
      ;;
    --non-interactive)
      NONINTERACTIVE=1; shift 1
      ;;
    -h|--help)
      print_usage; exit 0
      ;;
    *)
      # Unknown positional/flag
      print_error "Unknown option: $1"; print_usage; exit 1
      ;;
  esac
done

print_header "Verifying System Requirements"

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is not installed."
  echo -e "Please install git and pciutils are installed, then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

# Check for lspci (pciutils)
if ! command -v lspci &> /dev/null; then
  print_error "pciutils is not installed."
  echo -e "Please install git and pciutils,  then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

if [ -n "$(grep -i nixos < /etc/os-release)" ]; then
  echo -e "${GREEN}Verified this is NixOS.${NC}"
else
  print_error "This is not NixOS or the distribution information is not available."
  exit 1
fi

print_header "Initial Setup"

echo -e "Default options are in brackets []"
echo -e "Just press enter to select the default"
sleep 2

print_header "Locate or clone ddubsOS repository"
REPO_DIR=""
# Determine default URL precedence if not explicitly provided
if [ -z "$REPO_URL" ]; then
  if [ $FORCE_GITLAB -eq 1 ]; then
    REPO_URL="$REPO_URL_GL"
  else
    REPO_URL="$REPO_URL_GH"
  fi
fi

if [ -f "$LOG_DIR/flake.nix" ] && [ -d "$LOG_DIR/.git" ]; then
  REPO_DIR="$LOG_DIR"
  echo -e "${GREEN}Using repository at script directory: $REPO_DIR${NC}"
elif [ -d "$HOME/ddubsos/.git" ]; then
  REPO_DIR="$HOME/ddubsos"
  echo -e "${GREEN}Using existing repository: $REPO_DIR${NC}"
  (
    cd "$HOME/ddubsos" &&
    echo -e "Fetching latest from remote..." &&
    git fetch --all --prune &&
    echo -e "Checking out branch: $BRANCH" &&
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" &&
    git pull --ff-only || true
  )
else
  echo -e "${GREEN}Repository not found. Cloning to $HOME/ddubsos${NC}"
  echo -e "Attempting: $REPO_URL (branch: $BRANCH)"
  if ! git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$HOME/ddubsos"; then
    echo -e "${RED}Primary clone failed. Attempting fallback mirror...${NC}"
    FALLBACK_URL=$([ "$REPO_URL" = "$REPO_URL_GH" ] && echo "$REPO_URL_GL" || echo "$REPO_URL_GH")
    echo -e "Attempting fallback: $FALLBACK_URL (branch: $BRANCH)"
    git clone --branch "$BRANCH" --single-branch "$FALLBACK_URL" "$HOME/ddubsos" || {
      print_error "Failed to clone repository from both $REPO_URL and $FALLBACK_URL"
      exit 1
    }
  fi
  REPO_DIR="$HOME/ddubsos"
fi
cd "$REPO_DIR" || exit 1
echo -e "${GREEN}Current directory: $(pwd)${NC}"

print_header "Hostname Configuration"
echo -e "⚠️  ${RED}Important: Do NOT use 'default' as hostname - it will be overwritten on updates!${NC}"
echo -e "Suggested hostnames: my-desktop, my-laptop, workstation, gaming-pc, home-server"
echo -e ""
if [ -n "$HOST_CLI" ]; then
  hostName="$HOST_CLI"
  echo -e "Using hostname from CLI: $hostName"
else
  if [ $NONINTERACTIVE -eq 1 ]; then
    hostName="my-desktop"
    echo -e "Non-interactive: defaulting hostname to $hostName"
  else
    read -rp "Enter Your New Hostname: [ my-desktop ] " hostName
    if [ -z "$hostName" ]; then
      hostName="my-desktop"
    fi
  fi
fi
echo -e "${GREEN}Selected hostname: $hostName${NC}"

print_header "GPU Profile Detection"

# Attempt automatic detection
DETECTED_PROFILE=""

has_nvidia=false
has_intel=false
has_amd=false
has_vm=false

if lspci | grep -qi 'vga\|3d'; then
  while read -r line; do
    if echo "$line" | grep -qi 'nvidia'; then
      has_nvidia=true
    elif echo "$line" | grep -qi 'amd'; then
      has_amd=true
    elif echo "$line" | grep -qi 'intel'; then
      has_intel=true
    elif echo "$line" | grep -qi 'virtio\|vmware'; then
      has_vm=true
    fi
  done < <(lspci | grep -i 'vga\|3d')

  if $has_vm; then
    DETECTED_PROFILE="vm"
  elif $has_nvidia && $has_intel; then
    DETECTED_PROFILE="nvidia-laptop"
  elif $has_nvidia && $has_amd; then
    DETECTED_PROFILE="amd-hybrid"
  elif $has_nvidia; then
    DETECTED_PROFILE="nvidia"
  elif $has_amd; then
    DETECTED_PROFILE="amd"
  elif $has_intel; then
    DETECTED_PROFILE="intel"
  fi
fi

# Handle detected profile or fall back to manual input
# CLI override takes precedence
if [ -n "$PROFILE_CLI" ]; then
  profile="$PROFILE_CLI"
  echo -e "Using profile from CLI: $profile"
elif [ -n "$DETECTED_PROFILE" ]; then
  profile="$DETECTED_PROFILE"
  echo -e "${GREEN}Detected GPU profile: $profile${NC}"
  if [ $NONINTERACTIVE -eq 1 ]; then
    echo -e "Non-interactive: accepting detected profile"
  else
    read -p "Correct? (Y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${RED}GPU profile not confirmed. Falling back to manual selection.${NC}"
      profile="" # Clear profile to force manual input
    fi
  fi
fi

# If profile is still empty (either not detected or not confirmed), prompt manually
if [ -z "$profile" ]; then
  if [ $NONINTERACTIVE -eq 1 ]; then
    profile="amd"
    echo -e "Non-interactive: defaulting profile to $profile"
  else
    echo -e "${RED}Automatic GPU detection failed or no specific profile found.${NC}"
printf "Enter Your Hardware Profile (GPU)\nOptions:\n[ amd ]\nnvidia\nnvidia-laptop\namd-hybrid\nintel\nvm\nPlease type out your choice: "
    read -r profile
    if [ -z "$profile" ]; then
      profile="amd"
    fi
    echo -e "${GREEN}Selected GPU profile: $profile${NC}"
  fi
fi




print_header "Configuring Host and Profile"
mkdir -p hosts/"$hostName"
cp hosts/default/*.nix hosts/"$hostName"

installusername=$(echo $USER)

sed -i "/^[[:space:]]*host[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$hostName\"/" ./flake.nix
sed -i "/^[[:space:]]*profile[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$profile\"/" ./flake.nix

print_header "Timezone Configuration"
echo -e "Common timezones:"
echo -e "  America/New_York    (Eastern Time)"
echo -e "  America/Chicago     (Central Time)"
echo -e "  America/Denver      (Mountain Time)"
echo -e "  America/Los_Angeles (Pacific Time)"
echo -e "  Europe/London       (GMT/BST)"
echo -e "  Europe/Paris        (CET/CEST)"
echo -e "  Asia/Tokyo          (JST)"
echo -e "  UTC                 (Coordinated Universal Time)"
echo -e ""
if [ $NONINTERACTIVE -eq 1 ]; then
  timeZone="America/New_York"
  echo -e "Non-interactive: defaulting timezone to $timeZone"
else
  read -rp "Enter your timezone: [America/New_York] " timeZone
  if [ -z "$timeZone" ]; then
    timeZone="America/New_York"
  fi
fi
echo -e "${GREEN}Selected timezone: $timeZone${NC}"
sed -i "s|time.timeZone = \".*\";|time.timeZone = \"$timeZone\";|" ./modules/core/system.nix

print_header "Git Configuration"
echo -e "📝 Git configuration for version control (used for commits and contributions)"
echo -e "💡 Use your real name and primary email address"
echo -e ""
if [ $NONINTERACTIVE -eq 1 ]; then
  gitUsername="YourName"
  gitEmail="your.email@example.com"
  echo -e "Non-interactive: using placeholder git identity ($gitUsername <$gitEmail>)"
else
  read -rp "Enter your Git username: [YourName] " gitUsername
  if [ -z "$gitUsername" ]; then
    gitUsername="YourName"
  fi
  read -rp "Enter your Git email: [your.email@example.com] " gitEmail
  if [ -z "$gitEmail" ]; then
    gitEmail="your.email@example.com"
  fi
fi
echo -e "${GREEN}Git configured: $gitUsername <$gitEmail>${NC}"
sed -i "s/gitUsername = \".*\";/gitUsername = \"$gitUsername\";/" ./hosts/$hostName/variables.nix
sed -i "s/gitEmail = \".*\";/gitEmail = \"$gitEmail\";/" ./hosts/$hostName/variables.nix


print_header "Keyboard Layout Configuration"
# Note: Display configuration defaults (legacy monitor lines) are in hosts/default/variables.nix.
# You can now use Hyprland monitorv2 via structured variables (hyprMonitorsV2) with enable flags and transform mapping.
# See docs/outline-move-monitorsv2-way-displays.md for multiple-monitor examples and transform values (0–7).

echo -e "Common keyboard layouts:"
echo -e "  us      (US QWERTY - most common)"
echo -e "  uk      (UK QWERTY)"
echo -e "  de      (German QWERTZ)"
echo -e "  fr      (French AZERTY)"
echo -e "  es      (Spanish QWERTY)"
echo -e "  it      (Italian QWERTY)"
echo -e "  dvorak  (Dvorak layout)"
echo -e "  colemak (Colemak layout)"
echo -e ""
if [ $NONINTERACTIVE -eq 1 ]; then
  keyboardLayout="us"
  echo -e "Non-interactive: defaulting keyboard layout to $keyboardLayout"
else
  read -rp "Enter your keyboard layout: [ us ] " keyboardLayout
  if [ -z "$keyboardLayout" ]; then
    keyboardLayout="us"
  fi
fi
echo -e "${GREEN}Selected keyboard layout: $keyboardLayout${NC}"
sed -i "/^[[:space:]]*keyboardLayout[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$keyboardLayout\"/" ./hosts/$hostName/variables.nix

print_header "Console Keymap Configuration"
echo -e "💡 Console keymap usually matches keyboard layout"
echo -e "Common console keymaps:"
echo -e "  us    (US layout)"
echo -e "  uk    (UK layout)"
echo -e "  de    (German layout)"
echo -e "  fr    (French layout)"
echo -e ""
if [ $NONINTERACTIVE -eq 1 ]; then
  consoleKeyMap="$keyboardLayout"
  echo -e "Non-interactive: defaulting console keymap to $consoleKeyMap"
else
  read -rp "Enter your console keymap: [ $keyboardLayout ] " consoleKeyMap
  if [ -z "$consoleKeyMap" ]; then
    consoleKeyMap="$keyboardLayout"  # Default to same as keyboard layout
  fi
fi
echo -e "${GREEN}Selected console keymap: $consoleKeyMap${NC}"
sed -i "/^[[:space:]]*consoleKeyMap[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$consoleKeyMap\"/" ./hosts/$hostName/variables.nix

print_header "Username Configuration"
sed -i "/^[[:space:]]*username[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$installusername\"/" ./flake.nix

print_header "Capturing Hardware Configuration"

# Prefer the system's existing hardware-configuration.nix. Validate strictly.
# If --regen-hw is passed, regenerate using nixos-generate-config.
# ddubsOS assumes NixOS is already installed; users manage disks/filesystems separately.

target="./hosts/$hostName/hardware.nix"

# If the system places fileSystems in /etc/nixos/configuration.nix (e.g., from a custom installer),
# append that block into our target hardware.nix before validating.
maybe_append_filesystems_from_system() {
  local tgt="$1"
  if grep -q 'fileSystems' "$tgt"; then
    return 0
  fi
  if [ -f /etc/nixos/configuration.nix ] && grep -q 'fileSystems' /etc/nixos/configuration.nix; then
    echo "Appending fileSystems from /etc/nixos/configuration.nix to $tgt"
    # Robustly extract the entire fileSystems attrset (brace-balanced)
    awk '
      BEGIN { start=0; depth=0 }
      {
        if (start) {
          print
          n_open=gsub(/\{/, "{"); n_close=gsub(/\}/, "}")
          depth += n_open - n_close
          if (depth<=0) exit
        } else if ($0 ~ /fileSystems[[:space:]]*=[[:space:]]*\{/) {
          start=1
          n_open=gsub(/\{/, "{"); n_close=gsub(/\}/, "}")
          depth = n_open - n_close
          print
          if (depth<=0) exit
        }
      }
    ' /etc/nixos/configuration.nix | sudo tee -a "$tgt" >/dev/null || true
  fi
}

# Ensure target hardware file is a valid Nix module (wrap if missing)
ensure_module_wrapper() {
  local f="$1"
  # Determine the first non-empty, non-comment line
  local first
  first=$(awk '{ gsub(/\r$/, ""); if ($0 ~ /^[[:space:]]*$/) next; if ($0 ~ /^[[:space:]]*#/) next; print; exit }' "$f")
  # If the file already appears to be a Nix module (has a module arg header), do nothing
  if printf '%s\n' "$first" | grep -q '^{[[:space:]]*config\b.*}:\s*$'; then
    return 0
  fi
  # If the file starts with an attribute set already, assume it is a module
  if printf '%s\n' "$first" | grep -q '^{[[:space:]]*'; then
    return 0
  fi
  # Otherwise, wrap existing content inside a minimal module to ensure validity
  local tmp
  tmp=$(mktemp)
  {
    printf '%s\n' '{ config, lib, modulesPath, ... }:'
    printf '%s\n' '{'
    cat "$f"
    printf '%s\n' '}'
  } > "$tmp"
  sudo tee "$f" < "$tmp" >/dev/null
  rm -f "$tmp"
}

# Extract root device from hardware.nix supporting both dotted and nested syntaxes
extract_root_device() {
  local f="$1"
  local out=""
  # Prefer dotted syntax block: fileSystems."/" = { ... device = "..." ... };
  out=$(awk '
    BEGIN { inroot=0 }
    /fileSystems\."\/"[[:space:]]*=/ { inroot=1 }
    inroot && match($0, /device[[:space:]]*=[[:space:]]*"([^"]+)"/, m) { print m[1]; exit }
    inroot && /};/ { inroot=0 }
  ' "$f")
  if [ -n "$out" ]; then
    printf '%s\n' "$out"; return 0
  fi
  # Fallback: nested syntax fileSystems = { "/" = { ... device = "..." ... }; ... };
  out=$(awk '
    BEGIN { in_fs=0; in_root=0; depth=0 }
    /fileSystems[[:space:]]*=[[:space:]]*\{/ { in_fs=1; depth+=gsub(/\{/, "{")-gsub(/\}/, "}") }
    in_fs && /"\/"[[:space:]]*=[[:space:]]*\{/ { in_root=1 }
    in_root && match($0, /device[[:space:]]*=[[:space:]]*"([^"]+)"/, m) { print m[1]; exit }
    {
      if (in_fs) { depth+=gsub(/\{/, "{")-gsub(/\}/, "}"); if (depth<=0) in_fs=0 }
      if (in_root && /\};/) { in_root=0 }
    }
  ' "$f")
  if [ -n "$out" ]; then
    printf '%s\n' "$out"; return 0
  fi
  return 1
}

is_hardware_valid() {
  local f="$1"
  # Must contain fileSystems with non-empty device strings
  if ! grep -q 'fileSystems' "$f"; then
    echo "Invalid hardware.nix: missing fileSystems attrset" >&2
    return 1
  fi
  if grep -q 'device *= *""' "$f"; then
    echo "Invalid hardware.nix: empty device entries detected" >&2
    return 1
  fi
  # Ensure root device appears non-empty (robust parsing)
  local cfg_root
  if ! cfg_root=$(extract_root_device "$f"); then
    echo "Invalid hardware.nix: root device missing/empty" >&2
    return 1
  fi
  # UUID symlinks referenced should exist (best-effort)
  local uuid
  while read -r uuid; do
    [ -e "/dev/disk/by-uuid/$uuid" ] || {
      echo "Invalid hardware.nix: missing /dev/disk/by-uuid/$uuid" >&2
      return 1
    }
  done < <(grep -oE '/dev/disk/by-uuid/[A-Fa-f0-9-]+' "$f" | awk -F/ '{print $5}' | sort -u)
  return 0
}

if [ "$REGEN_HW" -eq 1 ]; then
  echo "--regen-hw specified: generating hardware-configuration via nixos-generate-config"
sudo nixos-generate-config --root / --show-hardware-config | sudo tee "$target" >/dev/null
  maybe_append_filesystems_from_system "$target"
  ensure_module_wrapper "$target"
  if ! is_hardware_valid "$target"; then
    echo "ERROR: Generated hardware.nix appears invalid for this environment." >&2
    echo "       Please ensure you are running on the target NixOS install (not a live ISO) and try again." >&2
    exit 1
  fi
else
  if [ -f /etc/nixos/hardware-configuration.nix ]; then
    echo "Using /etc/nixos/hardware-configuration.nix"
sudo cp /etc/nixos/hardware-configuration.nix "$target"
    maybe_append_filesystems_from_system "$target"
    ensure_module_wrapper "$target"
    if ! is_hardware_valid "$target"; then
      echo "ERROR: /etc/nixos/hardware-configuration.nix appears stale or invalid." >&2
      echo "       Re-run this installer with --regen-hw to regenerate hardware.nix on this system." >&2
      exit 1
    fi
  else
    echo "ERROR: /etc/nixos/hardware-configuration.nix not found." >&2
    echo "       Re-run this installer with --regen-hw to generate a hardware.nix for this system." >&2
    exit 1
  fi
fi

print_header "Adding new host to Git"
git add .

print_header "Setting Nix Configuration"
NIX_CONFIG="experimental-features = nix-command flakes"

print_header "Initiating NixOS Build"
if [ $NONINTERACTIVE -eq 1 ]; then
  echo -e "Non-interactive: proceeding with initial build"
else
  read -p "Ready to run initial build? (Y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${RED}Build cancelled.${NC}"
      exit 1
  fi
fi

if [ $BUILD_HOST -eq 1 ]; then
  echo -e "Building by host target: ${hostName}"
  sudo nixos-rebuild boot --flake .#${hostName} --option accept-flake-config true --refresh
else
  echo -e "Building by profile target: ${profile}"
  sudo nixos-rebuild boot --flake .#${profile} --option accept-flake-config true --refresh
fi

# Check the exit status of the last command (nixos-rebuild)
if [ $? -eq 0 ]; then
  print_success_banner
else
  print_failure_banner
fi
