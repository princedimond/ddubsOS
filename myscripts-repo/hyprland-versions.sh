#!/usr/bin/env bash
# Display Hyprland and related package versions from flake.lock

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCK_FILE="$FLAKE_DIR/flake.lock"

# Default mode
MODE="short"
OUTPUT_JSON=false
OUTPUT_MARKDOWN=false

# Parse command line arguments
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Display Hyprland and related package versions from flake.lock

OPTIONS:
    -h, --help      Show this help message
    -f, --full      Show detailed information (full commit hashes, types, etc.)
    -j, --json      Output in JSON format
    -m, --markdown  Output in Markdown format
    
EXAMPLES:
    $(basename "$0")              # Show short summary (default)
    $(basename "$0") --full       # Show detailed information
    $(basename "$0") --json       # Output as JSON
    $(basename "$0") --markdown   # Output as Markdown table

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -f|--full)
            MODE="full"
            shift
            ;;
        -j|--json)
            OUTPUT_JSON=true
            shift
            ;;
        -m|--markdown)
            OUTPUT_MARKDOWN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

if [[ ! -f "$LOCK_FILE" ]]; then
    echo "Error: flake.lock not found at $LOCK_FILE"
    exit 1
fi

# Function to extract version info for a package using grep/sed
extract_package_data() {
    local pkg_name="$1"
    
    # Find the package section in the lock file
    local in_section=0
    local section_content=""
    local brace_count=0
    local found=0
    
    while IFS= read -r line; do
        # Check if we found the start of our package
        if [[ "$line" =~ \"$pkg_name\":[[:space:]]*\{ ]]; then
            in_section=1
            found=1
            brace_count=1
            continue
        fi
        
        if [[ $in_section -eq 1 ]]; then
            section_content+="$line"$'\n'
            
            # Count braces to know when section ends
            open_braces=$(echo "$line" | grep -o '{' | wc -l || echo 0)
            close_braces=$(echo "$line" | grep -o '}' | wc -l || echo 0)
            brace_count=$((brace_count + open_braces - close_braces))
            
            if [[ $brace_count -eq 0 ]]; then
                break
            fi
        fi
    done < "$LOCK_FILE"
    
    if [[ $found -eq 0 ]]; then
        return 1
    fi
    
    # Extract locked section
    local locked_section=$(echo "$section_content" | sed -n '/"locked":/,/}/p')
    
    if [[ -z "$locked_section" ]]; then
        return 1
    fi
    
    # Extract individual fields
    PKG_REV=$(echo "$locked_section" | grep -o '"rev": "[^"]*"' | cut -d'"' -f4 | head -1)
    PKG_REF=$(echo "$locked_section" | grep -o '"ref": "[^"]*"' | cut -d'"' -f4 | head -1)
    PKG_TYPE=$(echo "$locked_section" | grep -o '"type": "[^"]*"' | cut -d'"' -f4 | head -1)
    PKG_LASTMOD=$(echo "$locked_section" | grep -o '"lastModified": [0-9]*' | grep -o '[0-9]*' | head -1)
    PKG_OWNER=$(echo "$locked_section" | grep -o '"owner": "[^"]*"' | cut -d'"' -f4 | head -1)
    PKG_REPO=$(echo "$locked_section" | grep -o '"repo": "[^"]*"' | cut -d'"' -f4 | head -1)
    
    # For git type, extract URL
    if [[ "$PKG_TYPE" == "git" ]]; then
        PKG_URL=$(echo "$locked_section" | grep -o '"url": "[^"]*"' | cut -d'"' -f4 | head -1)
    fi
    
    return 0
}

# Build GitHub URL for a commit
build_github_url() {
    local owner="$1"
    local repo="$2"
    local rev="$3"
    local url="$4"
    local type="$5"
    
    if [[ "$type" == "github" && -n "$owner" && -n "$repo" && -n "$rev" ]]; then
        echo "https://github.com/$owner/$repo/commit/$rev"
    elif [[ "$type" == "git" && -n "$url" ]]; then
        # Try to convert git URL to GitHub URL
        if [[ "$url" =~ github\.com[:/]([^/]+)/([^.]+) ]]; then
            local gh_owner="${BASH_REMATCH[1]}"
            local gh_repo="${BASH_REMATCH[2]%.git}"
            echo "https://github.com/$gh_owner/$gh_repo/commit/$rev"
        fi
    fi
}

# Display package info in short format
display_short() {
    local display_name="$1"
    local rev="$2"
    local lastmod="$3"
    local owner="$4"
    local repo="$5"
    local url="$6"
    local type="$7"
    
    local short_rev="${rev:0:7}"
    local date=""
    
    if [[ -n "$lastmod" ]]; then
        date=$(date -d "@$lastmod" "+%Y-%m-%d" 2>/dev/null || echo "unknown")
    else
        date="unknown"
    fi
    
    # Create clickable link using ANSI escape codes (works in most modern terminals)
    local github_url=$(build_github_url "$owner" "$repo" "$rev" "$url" "$type")
    if [[ -n "$github_url" ]]; then
        # Use OSC 8 hyperlink format: \e]8;;URL\e\\text\e]8;;\e\\
        local link=$'\e]8;;'"${github_url}"$'\e\\'"${short_rev}"$'\e]8;;\e\\'
        printf "%-30s %-8s (%s)\n" "$display_name" "$link" "$date"
    else
        printf "%-30s %-8s (%s)\n" "$display_name" "$short_rev" "$date"
    fi
}

# Display package info in markdown format
display_markdown() {
    local display_name="$1"
    local rev="$2"
    local lastmod="$3"
    local owner="$4"
    local repo="$5"
    local url="$6"
    local type="$7"
    
    local short_rev="${rev:0:7}"
    local date=""
    
    if [[ -n "$lastmod" ]]; then
        date=$(date -d "@$lastmod" "+%Y-%m-%d" 2>/dev/null || echo "unknown")
    else
        date="unknown"
    fi
    
    # Build GitHub URL for markdown link
    local github_url=$(build_github_url "$owner" "$repo" "$rev" "$url" "$type")
    if [[ -n "$github_url" ]]; then
        printf "| %-28s | [%s](%s) | %s |\n" "$display_name" "$short_rev" "$github_url" "$date"
    else
        printf "| %-28s | %s | %s |\n" "$display_name" "$short_rev" "$date"
    fi
}

# Display package info in full format
display_full() {
    local display_name="$1"
    local rev="$2"
    local ref="$3"
    local type="$4"
    local lastmod="$5"
    local owner="$6"
    local repo="$7"
    local url="$8"
    
    echo "┌─ $display_name"
    echo "│"
    
    # Build GitHub URL if possible
    local github_url=$(build_github_url "$owner" "$repo" "$rev" "$url" "$type")
    
    if [[ -n "$rev" ]]; then
        echo "│  Rev: ${rev:0:12}...${rev: -4}"
        if [[ -n "$github_url" ]]; then
            # Create clickable link
            echo -e "│  URL: "$'\e]8;;'"${github_url}"$'\e\\'"${github_url}"$'\e]8;;\e\\'
        fi
    else
        echo "│  Rev: N/A"
    fi
    
    [[ -n "$ref" ]] && echo "│  Ref: $ref" || echo "│  Ref: N/A"
    [[ -n "$type" ]] && echo "│  Type: $type" || echo "│  Type: N/A"
    
    if [[ -n "$lastmod" ]]; then
        local date=$(date -d "@$lastmod" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "N/A")
        echo "│  Date: $date"
        echo "│  Full Rev: $rev"
    fi
    echo "└─"
    echo ""
}

# Add package to JSON array
add_to_json() {
    local pkg_name="$1"
    local display_name="$2"
    local rev="$3"
    local ref="$4"
    local type="$5"
    local lastmod="$6"
    local owner="$7"
    local repo="$8"
    local url="$9"
    
    local date=""
    if [[ -n "$lastmod" ]]; then
        date=$(date -d "@$lastmod" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
    else
        date="unknown"
    fi
    
    # Build GitHub URL
    local github_url=$(build_github_url "$owner" "$repo" "$rev" "$url" "$type")
    
    # Add comma if not first entry
    if [[ "$JSON_FIRST" != "true" ]]; then
        JSON_OUTPUT+=","
    fi
    JSON_FIRST="false"
    
    JSON_OUTPUT+=$(cat << EOF

    {
      "package": "$pkg_name",
      "name": "$display_name",
      "rev": "${rev:-null}",
      "ref": "${ref:-null}",
      "type": "${type:-null}",
      "lastModified": ${lastmod:-null},
      "date": "$date",
      "url": "${github_url:-null}"
    }
EOF
)
}

# Process a package
process_package() {
    local pkg_name="$1"
    local display_name="$2"
    
    if extract_package_data "$pkg_name"; then
        if [[ "$OUTPUT_JSON" == "true" ]]; then
            add_to_json "$pkg_name" "$display_name" "$PKG_REV" "$PKG_REF" "$PKG_TYPE" "$PKG_LASTMOD" "$PKG_OWNER" "$PKG_REPO" "$PKG_URL"
        elif [[ "$OUTPUT_MARKDOWN" == "true" ]]; then
            display_markdown "$display_name" "$PKG_REV" "$PKG_LASTMOD" "$PKG_OWNER" "$PKG_REPO" "$PKG_URL" "$PKG_TYPE"
        elif [[ "$MODE" == "short" ]]; then
            display_short "$display_name" "$PKG_REV" "$PKG_LASTMOD" "$PKG_OWNER" "$PKG_REPO" "$PKG_URL" "$PKG_TYPE"
        else
            display_full "$display_name" "$PKG_REV" "$PKG_REF" "$PKG_TYPE" "$PKG_LASTMOD" "$PKG_OWNER" "$PKG_REPO" "$PKG_URL"
        fi
    fi
}

# Initialize JSON output if needed
if [[ "$OUTPUT_JSON" == "true" ]]; then
    JSON_OUTPUT='{'
    JSON_OUTPUT+=$'\n  "packages": ['
    JSON_FIRST="true"
fi

# Header for non-JSON output
if [[ "$OUTPUT_JSON" != "true" ]]; then
    if [[ "$OUTPUT_MARKDOWN" == "true" ]]; then
        echo "# Hyprland Ecosystem Versions"
        echo ""
        echo "| Package | Commit | Date |"
        echo "|---------|--------|------|"
    elif [[ "$MODE" == "short" ]]; then
        echo "Hyprland Ecosystem Versions"
        echo "════════════════════════════════════════════════════════════"
        printf "%-30s %-8s %s\n" "Package" "Commit" "Date"
        echo "────────────────────────────────────────────────────────────"
    else
        echo "════════════════════════════════════════════════════════════"
        echo "  Hyprland Ecosystem Versions (from flake.lock)"
        echo "════════════════════════════════════════════════════════════"
        echo ""
    fi
fi

# Main Hyprland packages
process_package "hyprland" "Hyprland"
process_package "aquamarine" "Aquamarine"
process_package "hyprcursor" "Hyprcursor"
process_package "hyprgraphics" "Hyprgraphics"
process_package "hyprlang" "Hyprlang"
process_package "hyprutils" "Hyprutils"
process_package "hyprland-protocols" "Hyprland-Protocols"
process_package "hyprwayland-scanner" "Hyprwayland-Scanner"
process_package "xdph" "XDPH"
process_package "hyprpanel" "HyprPanel"

# Finalize output
if [[ "$OUTPUT_JSON" == "true" ]]; then
    JSON_OUTPUT+=$'\n  ],'
    
    # Add running Hyprland info if available
    JSON_OUTPUT+=$'\n  "running": {'
    if command -v hyprctl &> /dev/null; then
        HYPRCTL_OUTPUT=$(hyprctl version 2>/dev/null || echo "not_running")
        if [[ "$HYPRCTL_OUTPUT" != "not_running" ]]; then
            VERSION=$(echo "$HYPRCTL_OUTPUT" | head -1 | grep -o 'Hyprland [^ ]*' | cut -d' ' -f2 || echo "unknown")
            JSON_OUTPUT+=$'\n    "version": "'"$VERSION"'",'
            JSON_OUTPUT+=$'\n    "status": "running"'
        else
            JSON_OUTPUT+=$'\n    "status": "not_running"'
        fi
    else
        JSON_OUTPUT+=$'\n    "status": "not_installed"'
    fi
    JSON_OUTPUT+=$'\n  }'
    JSON_OUTPUT+=$'\n}'
    
    echo "$JSON_OUTPUT"
elif [[ "$OUTPUT_MARKDOWN" == "true" ]]; then
    echo ""
    echo "---"
    echo ""
    if command -v hyprctl &> /dev/null; then
        HYPR_VERSION=$(hyprctl version 2>/dev/null | head -1 || echo "Hyprland not running")
        echo "**Running:** $HYPR_VERSION"
    else
        echo "**Running:** Hyprland not running"
    fi
    echo ""
    echo "**Update commands:**"
    echo "- All packages: \`nix flake update\`"
    echo "- Hyprland only: \`nix flake lock --update-input hyprland\`"
else
    if [[ "$MODE" == "short" ]]; then
        echo "────────────────────────────────────────────────────────────"
        echo ""
        echo "Running: $(command -v hyprctl &> /dev/null && hyprctl version 2>/dev/null | head -1 || echo 'Hyprland not running')"
        echo ""
        echo "Update: nix flake update"
    else
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "Current running Hyprland version:"
        echo "────────────────────────────────────────────────────────────"
        if command -v hyprctl &> /dev/null; then
            hyprctl version 2>/dev/null || echo "Hyprland not currently running"
        else
            echo "hyprctl not found in PATH"
        fi
        echo ""
        echo "To update all packages: nix flake update"
        echo "To update only Hyprland: nix flake lock --update-input hyprland"
    fi
fi
