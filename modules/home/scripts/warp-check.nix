{pkgs}:
pkgs.writeShellScriptBin "warp-check" ''
  #!/usr/bin/env bash
  # Warp Terminal Version Checker
  # Compares stable (nixpkgs-stable: warp-terminal) vs latest (most recent: warp-bld) versions

  set -euo pipefail

  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color
  BOLD='\033[1m'

  echo -e "''${BOLD}''${CYAN}🚀 Warp Terminal Version Checker''${NC}"
  echo -e "''${BLUE}════════════════════════════════════════''${NC}"

  # Check if executables exist
  if ! command -v warp-terminal >/dev/null 2>&1; then
    echo -e "''${RED}❌ warp-terminal not found''${NC}"
    stable_available=false
  else
    stable_available=true
  fi

  if ! command -v warp-bld >/dev/null 2>&1; then
    echo -e "''${RED}❌ warp-bld not found''${NC}"
    bleeding_available=false
  else
    bleeding_available=true
  fi


  if [ "$stable_available" = false ] && [ "$bleeding_available" = false ]; then
    echo -e "''${RED}❌ Neither warp-terminal nor warp-bld are available''${NC}"
    exit 1
  fi

  # Function to extract version from debug info
  get_warp_version() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Warp version: Not available"
      return 1
    fi

    # Use timeout to prevent hanging and capture only the version line
    local line version
    line=$(timeout 10s "$cmd" dump-debug-info 2>/dev/null | grep -F "Warp version" | head -1 || true)

    # Extract just the version from common patterns produced by Warp (Rust Option formatting)
    if [[ "$line" =~ Some\\(\"([^\"]+)\"\\) ]]; then
      version="''${BASH_REMATCH[1]}"
    elif [[ "$line" =~ \"([^\"]+)\" ]]; then
      version="''${BASH_REMATCH[1]}"
    elif [[ "$line" =~ Warp\ version:\ ([^[:space:]]+) ]]; then
      version="''${BASH_REMATCH[1]}"
    else
      echo "Warp version: Unable to determine"
      return 1
    fi

    echo "Warp version: $version"
  }

  # Function to parse version date
  parse_version_date() {
    local version="$1"
    # Extract date from version string like "v0.2025.09.10.08.11.stable_01"
    if [[ "$version" =~ v0\.([0-9]{4})\.([0-9]{2})\.([0-9]{2})\. ]]; then
      echo "''${BASH_REMATCH[1]}-''${BASH_REMATCH[2]}-''${BASH_REMATCH[3]}"
    else
      echo "unknown"
    fi
  }

  # Function to compare versions
  compare_versions() {
    local label1="$1"
    local ver1="$2"
    local label2="$3"
    local ver2="$4"

    # Extract clean version strings from possible formats
    clean1="$ver1"
    clean2="$ver2"

    # Handle quoted form: "v0.x..."
    if [[ "$clean1" =~ \"([^\"]+)\" ]]; then clean1="''${BASH_REMATCH[1]}"; fi
    if [[ "$clean2" =~ \"([^\"]+)\" ]]; then clean2="''${BASH_REMATCH[1]}"; fi

    # Handle prefixed form: "Warp version: v0.x..."
    if [[ "$clean1" =~ ^Warp\ version:\ (.*)$ ]]; then clean1="''${BASH_REMATCH[1]}"; fi
    if [[ "$clean2" =~ ^Warp\ version:\ (.*)$ ]]; then clean2="''${BASH_REMATCH[1]}"; fi

    # Parse dates
    date1=$(parse_version_date "$clean1")
    date2=$(parse_version_date "$clean2")

    echo -e "\n''${BOLD}''${YELLOW}📊 Version Comparison:''${NC}"
    echo -e "  ''${BLUE}''${label1}:''${NC}        $clean1 (''${date1})"
    echo -e "  ''${CYAN}''${label2}:''${NC} $clean2 (''${date2})"

    if [[ "$date2" > "$date1" ]]; then
      echo -e "  ''${GREEN}✅ ''${label2} is newer''${NC}"
    elif [[ "$date2" = "$date1" ]]; then
      # Special case: when comparing preview vs warp-bld on the same date, assume preview is newer
      if [[ "''${label1}" == *"warp-bld"* && "''${label2}" == *"warp-preview"* ]]; then
        echo -e "  ''${GREEN}✅ ''${label2} is newer (same date, preview branch)''${NC}"
      elif [[ "''${label1}" == *"warp-preview"* && "''${label2}" == *"warp-bld"* ]]; then
        echo -e "  ''${GREEN}✅ ''${label1} is newer (same date, preview branch)''${NC}"
      else
        echo -e "  ''${YELLOW}⚖️  Versions are from the same date''${NC}"
      fi
    else
      echo -e "  ''${RED}⚠️  ''${label1} appears newer (unexpected)''${NC}"
    fi
  }

  # Get executable paths
  if [ "$stable_available" = true ]; then
    stable_path=$(readlink -f "$(which warp-terminal)")
    echo -e "''${BLUE}📦 Stable path:''${NC}        $stable_path"
  fi

  if [ "$bleeding_available" = true ]; then
    bleeding_path=$(readlink -f "$(which warp-bld)")
    echo -e "''${CYAN}📦 Latest (warp-bld) path:''${NC} $bleeding_path"
  fi


  echo ""

  # Get versions
  if [ "$stable_available" = true ]; then
    echo -e "''${BLUE}🔍 Checking stable version...''${NC}"
    stable_version=$(get_warp_version "warp-terminal")
    echo -e "  ''${stable_version}"
  else
    stable_version="Not available"
  fi

  if [ "$bleeding_available" = true ]; then
    echo -e "''${CYAN}🔍 Checking latest (warp-bld) version...''${NC}"
    bleeding_version=$(get_warp_version "warp-bld")
    echo -e "  ''${bleeding_version}"
  else
    bleeding_version="Not available"
  fi


  # Compare if pairs are available
  if [ "$stable_available" = true ] && [ "$bleeding_available" = true ]; then
    compare_versions "Stable (nixpkgs-stable)" "$stable_version" "Latest (warp-bld)" "$bleeding_version"
  fi

  # Show desktop integration info
  echo -e "\n''${BOLD}''${YELLOW}🖥️  Desktop Integration:''${NC}"
  if [ -f "/etc/applications/warp-bld.desktop" ]; then
    echo -e "  ''${GREEN}✅ GUI launcher available:''${NC} 'Warp-bld'"
  else
    echo -e "  ''${RED}❌ GUI launcher not found for warp-bld''${NC}"
  fi

  # Show quick launch commands
  echo -e "\n''${BOLD}''${YELLOW}🚀 Quick Launch Commands:''${NC}"
  if [ "$stable_available" = true ]; then
    echo -e "  ''${BLUE}Stable (nixpkgs-stable):''${NC}        warp-terminal"
  fi
  if [ "$bleeding_available" = true ]; then
    echo -e "  ''${CYAN}Latest (warp-bld):''${NC} warp-bld"
  fi

  echo -e "\n''${BOLD}''${YELLOW}💡 Troubleshooting:''${NC}"
  echo -e "  • If Warp shows 'update available' on an older version, try the latest (warp-bld) version"
  echo -e "  • Use ''${CYAN}warp-bld''${NC} for latest features and updates"
  echo -e "  • Use ''${BLUE}warp-terminal''${NC} for the stable, tested version (nixpkgs-stable)"

  echo -e "\n''${GREEN}✨ Check complete!''${NC}"
''
