{ pkgs }:

pkgs.writeShellScriptBin "warp-check" ''
  #!/usr/bin/env bash
  # Warp Terminal Version Checker
  # Compares stable (warp-terminal) vs bleeding-edge (warp-bld) versions
  
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
    if command -v "$cmd" >/dev/null 2>&1; then
      # Use timeout to prevent hanging and capture only the version line
      if timeout 10s "$cmd" dump-debug-info 2>/dev/null | grep "Warp version" | head -1; then
        return 0
      else
        echo "Warp version: Unable to determine"
        return 1
      fi
    else
      echo "Warp version: Not available"
      return 1
    fi
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
    local stable_ver="$1"
    local bleeding_ver="$2"
    
    # Extract clean version strings
    stable_clean=$(echo "$stable_ver" | sed 's/.*"\(.*\)".*/\1/')
    bleeding_clean=$(echo "$bleeding_ver" | sed 's/.*"\(.*\)".*/\1/')
    
    # Parse dates
    stable_date=$(parse_version_date "$stable_clean")
    bleeding_date=$(parse_version_date "$bleeding_clean")
    
    echo -e "\n''${BOLD}''${YELLOW}📊 Version Comparison:''${NC}"
    echo -e "  ''${BLUE}Stable:''${NC}        $stable_clean (''${stable_date})"
    echo -e "  ''${CYAN}Bleeding-edge:''${NC} $bleeding_clean (''${bleeding_date})"
    
    if [[ "$bleeding_date" > "$stable_date" ]]; then
      echo -e "  ''${GREEN}✅ Bleeding-edge is newer''${NC}"
    elif [[ "$bleeding_date" = "$stable_date" ]]; then
      echo -e "  ''${YELLOW}⚖️  Versions are from the same date''${NC}"
    else
      echo -e "  ''${RED}⚠️  Stable appears newer (unusual)''${NC}"
    fi
  }
  
  # Get executable paths
  if [ "$stable_available" = true ]; then
    stable_path=$(readlink -f "$(which warp-terminal)")
    echo -e "''${BLUE}📦 Stable path:''${NC}        $stable_path"
  fi
  
  if [ "$bleeding_available" = true ]; then
    bleeding_path=$(readlink -f "$(which warp-bld)")  
    echo -e "''${CYAN}📦 Bleeding-edge path:''${NC} $bleeding_path"
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
    echo -e "''${CYAN}🔍 Checking bleeding-edge version...''${NC}"
    bleeding_version=$(get_warp_version "warp-bld")
    echo -e "  ''${bleeding_version}"
  else
    bleeding_version="Not available"  
  fi
  
  # Compare if both are available
  if [ "$stable_available" = true ] && [ "$bleeding_available" = true ]; then
    compare_versions "$stable_version" "$bleeding_version"
  fi
  
  # Show desktop integration info
  echo -e "\n''${BOLD}''${YELLOW}🖥️  Desktop Integration:''${NC}"
  if [ -f "/etc/applications/warp-bld.desktop" ]; then
    echo -e "  ''${GREEN}✅ GUI launcher available:''${NC} 'Warp-bld'"
  else
    echo -e "  ''${RED}❌ GUI launcher not found''${NC}"
  fi
  
  # Show quick launch commands
  echo -e "\n''${BOLD}''${YELLOW}🚀 Quick Launch Commands:''${NC}"
  if [ "$stable_available" = true ]; then
    echo -e "  ''${BLUE}Stable:''${NC}        warp-terminal"
  fi
  if [ "$bleeding_available" = true ]; then
    echo -e "  ''${CYAN}Bleeding-edge:''${NC} warp-bld"
  fi
  
  echo -e "\n''${BOLD}''${YELLOW}💡 Troubleshooting:''${NC}"
  echo -e "  • If Warp shows 'update available' on old version, try the bleeding-edge version"
  echo -e "  • Use ''${CYAN}warp-bld''${NC} for latest features and updates"
  echo -e "  • Use ''${BLUE}warp-terminal''${NC} for stable, tested version"
  
  echo -e "\n''${GREEN}✨ Check complete!''${NC}"
''
