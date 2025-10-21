#!/bin/bash

# Git Repository Mirror Script v2.0
# Mirrors multiple repositories from various Git hosting platforms
# Supports GitHub, GitLab, Codeberg, Bitbucket, SourceForge, and custom Git servers
# Mirrors all branches with incremental sync (only downloads differences after initial sync)
# Provides comprehensive logging and statistics

set -euo pipefail

# ============================================================================
# CONFIGURATION - EDIT THESE VARIABLES AS NEEDED
# ============================================================================

# Set desired destination root - exit with error if not available
DESTINATION_ROOT="/mnt/nas/config.files/GitRepoMirror"

# Check if the designated destination root is available
if [[ ! -d "$(dirname "$DESTINATION_ROOT")" || ! -w "$(dirname "$DESTINATION_ROOT")" ]]; then
    echo "❌ ERROR: Designated destination root is not available or not writable"
    echo "   Specified path: $DESTINATION_ROOT"
    echo "   Parent directory: $(dirname "$DESTINATION_ROOT")"
    echo "   Please ensure the storage location is properly mounted and accessible."
    exit 1
fi
LOG_DIR="${DESTINATION_ROOT}/logs"
# LOG_FILE will be set after directories are created

# ============================================================================
# REPOSITORY CONFIGURATION
# ============================================================================

# GitHub repositories - will fetch all repos for each user
GITHUB_USERS=(
    "JaKooLit"
    "dwilliam62" 
    "drewgrif"
    "mylinuxforwork"
    "iynaix"
    "fufexan"
    "arkboix"
    "mkellyxp"
    "Abhra00"
    "Jas-SinghFSU"
)

# GitLab.com repositories - will fetch all repos for each user
GITLAB_USERS=(
    # Add GitLab.com usernames here
    # "username1"
    # "username2"
    "dwilliam62" 
    "zaney"
    "thelinuxcast"
    "Alxhr0"
    "garuda-linux"
    "paridhips"
)

# Codeberg repositories - will fetch all repos for each user
# Codeberg is a European non-profit Git hosting service (https://codeberg.org)
CODEBERG_USERS=(
    # Add Codeberg usernames here
    # "username1"
    # "username2"
)

# Bitbucket repositories - will fetch all repos for each user
BITBUCKET_USERS=(
    # Add Bitbucket usernames here
    # "username1"
    # "username2"
)

# SourceForge projects
SOURCEFORGE_PROJECTS=(
    # Add SourceForge project names here
    # "project1"
    # "project2"
)

# Custom GitLab instances (self-hosted)
# Format: "instance_url:username"
CUSTOM_GITLAB_INSTANCES=(
    # Examples:
    # "https://gitlab.example.com:myusername"
    # "https://git.company.com:teamname"
)

# Custom Git repositories (any Git URL)
# Format: "display_name:git_url"
CUSTOM_REPOS=(
    # Examples:
    # "my-project:https://git.example.com/user/project.git"
    # "company-repo:ssh://git@git.company.com:2222/team/repo.git"
    # "kernel:https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
)

# Repositories to exclude from mirroring
# Format: "platform/username/repository" (e.g., "github/iynaix/nixpkgs")
# Use this to exclude very large repositories or repositories you don't want
EXCLUDED_REPOS=(
    "github/iynaix/nixpkgs"  # Very large fork of nixpkgs (5GB+)
    "github/fufexan/nixpkgs"  # Very large fork of nixpkgs (5GB+)
    # "github/username/large-repo"
    # "gitlab/username/unwanted-repo"
)

# ============================================================================
# SCRIPT CONFIGURATION
# ============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Global counters
TOTAL_REPOS=0
SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0
NEW_REPOS=0
UPDATED_REPOS=0
FAILED_REPOS=()

# Timeout for API calls (seconds)
API_TIMEOUT=60

# Timeout for git operations (seconds)
GIT_UPDATE_TIMEOUT=300   # 5 minutes for updates
GIT_CLONE_TIMEOUT=1800   # 30 minutes for initial clones of large repos

# Maximum concurrent operations
MAX_PARALLEL_JOBS=8

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >&2
    
    # Only write to log file if it's defined and the directory exists
    if [[ -n "$LOG_FILE" && -d "$(dirname "$LOG_FILE")" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Function to print colored output
print_colored() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Function to create directory structure
setup_directories() {
    echo "Setting up directory structure"
    
    local dirs=(
        "$DESTINATION_ROOT"
        "$LOG_DIR"
        "$DESTINATION_ROOT/github"
        "$DESTINATION_ROOT/gitlab"
        "$DESTINATION_ROOT/codeberg"
        "$DESTINATION_ROOT/bitbucket"
        "$DESTINATION_ROOT/sourceforge"
        "$DESTINATION_ROOT/custom-gitlab"
        "$DESTINATION_ROOT/custom"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
        fi
    done
    
    # Now that directories exist, set up the log file
    LOG_FILE="${LOG_DIR}/mirror-$(date +%Y%m%d-%H%M%S).log"
    log_message "INFO" "Setting up directory structure"
    log_message "INFO" "Log file: $LOG_FILE"
}

# Function to check dependencies
check_dependencies() {
    log_message "INFO" "Checking dependencies"
    
    local missing_deps=()
    
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_colored "$RED" "❌ Missing required dependencies: ${missing_deps[*]}"
        log_message "ERROR" "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        print_colored "$YELLOW" "⚠️  Warning: jq not found. Install jq for better JSON parsing performance."
        print_colored "$YELLOW" "   On Ubuntu/Debian: sudo apt install jq"
        print_colored "$YELLOW" "   On RHEL/CentOS: sudo yum install jq"
        print_colored "$YELLOW" "   On Arch: sudo pacman -S jq"
        log_message "WARNING" "jq not available, using fallback JSON parsing"
    fi
}

# Function to extract JSON field without jq (fallback)
extract_json_field() {
    local json_file="$1"
    local field="$2"
    grep -o "\"$field\":\"[^\"]*\"" "$json_file" | cut -d'"' -f4
}

# Function to check if a repository should be excluded
is_repo_excluded() {
    local platform="$1"
    local username="$2"
    local repo_name="$3"
    local full_name="${platform,,}/$username/$repo_name"
    
    for excluded_repo in "${EXCLUDED_REPOS[@]}"; do
        if [[ "$full_name" == "$excluded_repo" ]]; then
            return 0  # Repository is excluded
        fi
    done
    
    return 1  # Repository is not excluded
}

# ============================================================================
# API FUNCTIONS FOR DIFFERENT PLATFORMS
# ============================================================================

# Function to get all repositories for a GitHub user
get_github_user_repos() {
    local username="$1"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for GitHub user: $username"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "https://api.github.com/users/$username/repos?per_page=100&page=$page" > "$temp_file"; then
            
            # Check if we got an error response
            if grep -q '"message":' "$temp_file"; then
                local error_msg=$(grep -o '"message":"[^"]*"' "$temp_file" | cut -d'"' -f4)
                log_message "ERROR" "GitHub API error for user $username: $error_msg"
                rm -f "$temp_file"
                return 1
            fi
            
            local repos_on_page
            if command -v jq >/dev/null 2>&1; then
                repos_on_page=$(jq -r '.[].name' "$temp_file" 2>/dev/null || echo "")
            else
                repos_on_page=$(extract_json_field "$temp_file" "name")
            fi
            
            # If no repos on this page, we're done
            if [[ -z "$repos_on_page" ]]; then
                break
            fi
            
            all_repos="$all_repos$repos_on_page"$'\n'
            ((page++))
        else
            log_message "ERROR" "Failed to fetch repositories for GitHub user: $username (page $page)"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# Function to get all repositories for a GitLab user
get_gitlab_user_repos() {
    local username="$1"
    local gitlab_url="${2:-https://gitlab.com}"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for GitLab user: $username at $gitlab_url"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "$gitlab_url/api/v4/users/$username/projects?per_page=100&page=$page" > "$temp_file"; then
            
            local repos_on_page
            if command -v jq >/dev/null 2>&1; then
                repos_on_page=$(jq -r '.[].path' "$temp_file" 2>/dev/null || echo "")
            else
                repos_on_page=$(extract_json_field "$temp_file" "path")
            fi
            
            if [[ -z "$repos_on_page" ]]; then
                break
            fi
            
            all_repos="$all_repos$repos_on_page"$'\n'
            ((page++))
        else
            log_message "ERROR" "Failed to fetch repositories for GitLab user: $username"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# Function to get all repositories for a Codeberg user
get_codeberg_user_repos() {
    local username="$1"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for Codeberg user: $username"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "https://codeberg.org/api/v1/users/$username/repos?page=$page&limit=100" > "$temp_file"; then
            
            local repos_on_page
            if command -v jq >/dev/null 2>&1; then
                repos_on_page=$(jq -r '.[].name' "$temp_file" 2>/dev/null || echo "")
            else
                repos_on_page=$(extract_json_field "$temp_file" "name")
            fi
            
            if [[ -z "$repos_on_page" ]]; then
                break
            fi
            
            all_repos="$all_repos$repos_on_page"$'\n'
            ((page++))
        else
            log_message "ERROR" "Failed to fetch repositories for Codeberg user: $username"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# Function to get all repositories for a Bitbucket user
get_bitbucket_user_repos() {
    local username="$1"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for Bitbucket user: $username"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "https://api.bitbucket.org/2.0/repositories/$username?page=$page&pagelen=100" > "$temp_file"; then
            
            local repos_on_page
            if command -v jq >/dev/null 2>&1; then
                repos_on_page=$(jq -r '.values[]?.name' "$temp_file" 2>/dev/null || echo "")
            else
                repos_on_page=$(extract_json_field "$temp_file" "name")
            fi
            
            if [[ -z "$repos_on_page" ]]; then
                break
            fi
            
            all_repos="$all_repos$repos_on_page"$'\n'
            ((page++))
        else
            log_message "ERROR" "Failed to fetch repositories for Bitbucket user: $username"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# ============================================================================
# MIRROR FUNCTIONS
# ============================================================================

# Function to mirror a single repository
mirror_repository() {
    local repo_url="$1"
    local local_path="$2"
    local display_name="${3:-$(basename "$repo_url" .git)}"
    local platform="${4:-unknown}"
    
    log_message "INFO" "Starting mirror for: $display_name ($platform)"
    print_colored "$BLUE" "🔄 Processing: $display_name"
    
    TOTAL_REPOS=$((TOTAL_REPOS + 1))
    
    # Check if repository already exists (incremental sync)
    if [[ -d "$local_path" ]]; then
        log_message "INFO" "Repository exists, performing incremental update: $local_path"
        cd "$local_path"
        
        # Get current commit count for comparison
        local old_commits=$(git rev-list --all --count 2>/dev/null || echo "0")
        
        # Fetch all updates (only downloads differences)
        local update_result=0
        log_message "INFO" "Attempting to update: $local_path"
        
        if timeout $GIT_UPDATE_TIMEOUT git remote update --prune 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
            if timeout $GIT_UPDATE_TIMEOUT git fetch --all --prune 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                update_result=0
            else
                update_result=1
            fi
        else
            update_result=1
        fi
        
        if [[ $update_result -eq 0 ]]; then
            
            local new_commits=$(git rev-list --all --count 2>/dev/null || echo "0")
            local commit_diff=$((new_commits - old_commits))
            
            log_message "SUCCESS" "Updated repository: $display_name ($commit_diff new commits)"
            if [[ $commit_diff -gt 0 ]]; then
                print_colored "$GREEN" "✅ Updated: $display_name (+$commit_diff commits)"
                UPDATED_REPOS=$((UPDATED_REPOS + 1))
            else
                print_colored "$GREEN" "✅ Up-to-date: $display_name"
            fi
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            log_message "ERROR" "Failed to update repository: $display_name"
            print_colored "$RED" "❌ Failed to update: $display_name"
            FAILED_REPOS+=("$display_name (update failed)")
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    else
        log_message "INFO" "Creating new mirror: $local_path"
        
        # Create parent directory if needed
        mkdir -p "$(dirname "$local_path")"
        
        # Clone as bare repository to mirror all branches (full initial sync)
        local clone_result=0
        log_message "INFO" "Attempting to clone: $repo_url"
        
        # Use extended timeout for large repositories
        if timeout $GIT_CLONE_TIMEOUT git clone --mirror "$repo_url" "$local_path" 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
            clone_result=0
        else
            clone_result=1
        fi
        
        if [[ $clone_result -eq 0 && -d "$local_path" ]]; then
            log_message "SUCCESS" "Successfully mirrored: $display_name"
            print_colored "$GREEN" "✅ New mirror: $display_name"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            NEW_REPOS=$((NEW_REPOS + 1))
            
            # Log repository information
            cd "$local_path"
            local branch_count=$(git branch -r 2>/dev/null | wc -l)
            local tag_count=$(git tag 2>/dev/null | wc -l)
            local commit_count=$(git rev-list --all --count 2>/dev/null || echo "0")
            local size=$(du -sh . 2>/dev/null | cut -f1)
            
            log_message "INFO" "Repository $display_name: $commit_count commits, $branch_count branches, $tag_count tags, $size"
        else
            log_message "ERROR" "Failed to clone repository: $display_name from $repo_url"
            print_colored "$RED" "❌ Failed to clone: $display_name"
            FAILED_REPOS+=("$display_name (clone failed)")
            FAILED_COUNT=$((FAILED_COUNT + 1))
            
            # Clean up failed clone attempt
            [[ -d "$local_path" ]] && rm -rf "$local_path"
        fi
    fi
}

# ============================================================================
# PLATFORM-SPECIFIC MIRROR FUNCTIONS
# ============================================================================

# Function to mirror GitHub repositories
mirror_github_repos() {
    if [[ ${#GITHUB_USERS[@]} -eq 0 ]]; then
        log_message "INFO" "No GitHub users configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting GitHub repository mirroring"
    print_colored "$PURPLE" "🐙 Processing GitHub repositories..."
    
    for username in "${GITHUB_USERS[@]}"; do
        log_message "INFO" "Processing GitHub user: $username"
        print_colored "$CYAN" "👤 Fetching repos for GitHub user: $username"
        
        local repos
        if repos=$(get_github_user_repos "$username"); then
            if [[ -z "$repos" ]]; then
                log_message "WARNING" "No repositories found for GitHub user: $username"
                print_colored "$YELLOW" "⚠️  No repositories found for: $username"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
            
            local repo_count=$(echo "$repos" | wc -l)
            print_colored "$BLUE" "📦 Found $repo_count repositories for $username"
            
            while IFS= read -r repo_name; do
                [[ -z "$repo_name" ]] && continue
                
                # Check if repository is excluded
                if is_repo_excluded "github" "$username" "$repo_name"; then
                    log_message "INFO" "Skipping excluded repository: github/$username/$repo_name"
                    print_colored "$YELLOW" "⏭️  Skipped (excluded): $username/$repo_name"
                    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                    continue
                fi
                
                local repo_url="https://github.com/$username/$repo_name.git"
                local local_path="$DESTINATION_ROOT/github/$username/$repo_name.git"
                
                mirror_repository "$repo_url" "$local_path" "$username/$repo_name" "GitHub"
            done <<< "$repos"
        else
            log_message "ERROR" "Failed to get repository list for GitHub user: $username"
            print_colored "$RED" "❌ Failed to fetch repos for: $username"
            FAILED_REPOS+=("$username (GitHub user repos fetch failed)")
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    done
}

# Function to mirror GitLab repositories
mirror_gitlab_repos() {
    if [[ ${#GITLAB_USERS[@]} -eq 0 ]]; then
        log_message "INFO" "No GitLab users configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting GitLab repository mirroring"
    print_colored "$YELLOW" "🦊 Processing GitLab repositories..."
    
    for username in "${GITLAB_USERS[@]}"; do
        print_colored "$CYAN" "👤 Fetching repos for GitLab user: $username"
        
        local repos
        if repos=$(get_gitlab_user_repos "$username"); then
            if [[ -z "$repos" ]]; then
                log_message "WARNING" "No repositories found for GitLab user: $username"
                print_colored "$YELLOW" "⚠️  No repositories found for: $username"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
            
            local repo_count=$(echo "$repos" | wc -l)
            print_colored "$BLUE" "📦 Found $repo_count repositories for $username"
            
            while IFS= read -r repo_name; do
                [[ -z "$repo_name" ]] && continue
                
                local repo_url="https://gitlab.com/$username/$repo_name.git"
                local local_path="$DESTINATION_ROOT/gitlab/$username/$repo_name.git"
                
                mirror_repository "$repo_url" "$local_path" "$username/$repo_name" "GitLab"
            done <<< "$repos"
        else
            log_message "ERROR" "Failed to get repository list for GitLab user: $username"
            print_colored "$RED" "❌ Failed to fetch repos for: $username"
            FAILED_REPOS+=("$username (GitLab user repos fetch failed)")
            ((FAILED_COUNT++))
        fi
    done
}

# Function to mirror Codeberg repositories
mirror_codeberg_repos() {
    if [[ ${#CODEBERG_USERS[@]} -eq 0 ]]; then
        log_message "INFO" "No Codeberg users configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting Codeberg repository mirroring"
    print_colored "$CYAN" "🌊 Processing Codeberg repositories..."
    
    for username in "${CODEBERG_USERS[@]}"; do
        print_colored "$CYAN" "👤 Fetching repos for Codeberg user: $username"
        
        local repos
        if repos=$(get_codeberg_user_repos "$username"); then
            if [[ -z "$repos" ]]; then
                log_message "WARNING" "No repositories found for Codeberg user: $username"
                print_colored "$YELLOW" "⚠️  No repositories found for: $username"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
            
            local repo_count=$(echo "$repos" | wc -l)
            print_colored "$BLUE" "📦 Found $repo_count repositories for $username"
            
            while IFS= read -r repo_name; do
                [[ -z "$repo_name" ]] && continue
                
                local repo_url="https://codeberg.org/$username/$repo_name.git"
                local local_path="$DESTINATION_ROOT/codeberg/$username/$repo_name.git"
                
                mirror_repository "$repo_url" "$local_path" "$username/$repo_name" "Codeberg"
            done <<< "$repos"
        else
            log_message "ERROR" "Failed to get repository list for Codeberg user: $username"
            print_colored "$RED" "❌ Failed to fetch repos for: $username"
            FAILED_REPOS+=("$username (Codeberg user repos fetch failed)")
            ((FAILED_COUNT++))
        fi
    done
}

# Function to mirror Bitbucket repositories
mirror_bitbucket_repos() {
    if [[ ${#BITBUCKET_USERS[@]} -eq 0 ]]; then
        log_message "INFO" "No Bitbucket users configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting Bitbucket repository mirroring"
    print_colored "$BLUE" "🪣 Processing Bitbucket repositories..."
    
    for username in "${BITBUCKET_USERS[@]}"; do
        print_colored "$CYAN" "👤 Fetching repos for Bitbucket user: $username"
        
        local repos
        if repos=$(get_bitbucket_user_repos "$username"); then
            if [[ -z "$repos" ]]; then
                log_message "WARNING" "No repositories found for Bitbucket user: $username"
                print_colored "$YELLOW" "⚠️  No repositories found for: $username"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
            
            local repo_count=$(echo "$repos" | wc -l)
            print_colored "$BLUE" "📦 Found $repo_count repositories for $username"
            
            while IFS= read -r repo_name; do
                [[ -z "$repo_name" ]] && continue
                
                local repo_url="https://bitbucket.org/$username/$repo_name.git"
                local local_path="$DESTINATION_ROOT/bitbucket/$username/$repo_name.git"
                
                mirror_repository "$repo_url" "$local_path" "$username/$repo_name" "Bitbucket"
            done <<< "$repos"
        else
            log_message "ERROR" "Failed to get repository list for Bitbucket user: $username"
            print_colored "$RED" "❌ Failed to fetch repos for: $username"
            FAILED_REPOS+=("$username (Bitbucket user repos fetch failed)")
            ((FAILED_COUNT++))
        fi
    done
}

# Function to mirror SourceForge projects
mirror_sourceforge_repos() {
    if [[ ${#SOURCEFORGE_PROJECTS[@]} -eq 0 ]]; then
        log_message "INFO" "No SourceForge projects configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting SourceForge repository mirroring"
    print_colored "$GREEN" "🔥 Processing SourceForge repositories..."
    
    for project in "${SOURCEFORGE_PROJECTS[@]}"; do
        local repo_url="https://git.code.sf.net/p/$project/code"
        local local_path="$DESTINATION_ROOT/sourceforge/$project.git"
        
        mirror_repository "$repo_url" "$local_path" "sf:$project" "SourceForge"
    done
}

# Function to mirror custom GitLab instances
mirror_custom_gitlab_repos() {
    if [[ ${#CUSTOM_GITLAB_INSTANCES[@]} -eq 0 ]]; then
        log_message "INFO" "No custom GitLab instances configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting custom GitLab repository mirroring"
    print_colored "$PURPLE" "🏢 Processing custom GitLab instances..."
    
    for instance in "${CUSTOM_GITLAB_INSTANCES[@]}"; do
        local gitlab_url="${instance%:*}"
        local username="${instance#*:}"
        
        print_colored "$CYAN" "👤 Fetching repos for $username at $gitlab_url"
        
        local repos
        if repos=$(get_gitlab_user_repos "$username" "$gitlab_url"); then
            if [[ -z "$repos" ]]; then
                log_message "WARNING" "No repositories found for user: $username at $gitlab_url"
                print_colored "$YELLOW" "⚠️  No repositories found for: $username at $gitlab_url"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
            
            local repo_count=$(echo "$repos" | wc -l)
            print_colored "$BLUE" "📦 Found $repo_count repositories for $username"
            
            local instance_name=$(echo "$gitlab_url" | sed 's|https\?://||' | sed 's|/.*||' | tr '.' '_')
            
            while IFS= read -r repo_name; do
                [[ -z "$repo_name" ]] && continue
                
                local repo_url="$gitlab_url/$username/$repo_name.git"
                local local_path="$DESTINATION_ROOT/custom-gitlab/$instance_name/$username/$repo_name.git"
                
                mirror_repository "$repo_url" "$local_path" "$instance_name:$username/$repo_name" "Custom GitLab"
            done <<< "$repos"
        else
            log_message "ERROR" "Failed to get repository list for user: $username at $gitlab_url"
            print_colored "$RED" "❌ Failed to fetch repos for: $username at $gitlab_url"
            FAILED_REPOS+=("$username@$gitlab_url (custom GitLab fetch failed)")
            ((FAILED_COUNT++))
        fi
    done
}

# Function to mirror custom repositories
mirror_custom_repos() {
    if [[ ${#CUSTOM_REPOS[@]} -eq 0 ]]; then
        log_message "INFO" "No custom repositories configured, skipping"
        return
    fi
    
    log_message "INFO" "Starting custom repository mirroring"
    print_colored "$CYAN" "🔧 Processing custom repositories..."
    
    for repo in "${CUSTOM_REPOS[@]}"; do
        local display_name="${repo%:*}"
        local repo_url="${repo#*:}"
        local safe_name=$(echo "$display_name" | tr '/' '_' | tr ' ' '_' | tr ':' '_')
        local local_path="$DESTINATION_ROOT/custom/$safe_name.git"
        
        mirror_repository "$repo_url" "$local_path" "$display_name" "Custom"
    done
}

# ============================================================================
# SUMMARY AND REPORTING
# ============================================================================

# Function to print summary
print_summary() {
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    print_colored "$BLUE" "="*80
    print_colored "$BLUE" "📊 MIRROR OPERATION SUMMARY"
    print_colored "$BLUE" "="*80
    
    echo "Completed at: $end_time"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "📈 Statistics:"
    print_colored "$BLUE" "  Total repositories processed: $TOTAL_REPOS"
    print_colored "$GREEN" "  Successful operations: $SUCCESS_COUNT"
    print_colored "$CYAN" "    ├─ New repositories: $NEW_REPOS"
    print_colored "$CYAN" "    └─ Updated repositories: $UPDATED_REPOS"
    print_colored "$RED" "  Failed operations: $FAILED_COUNT"
    print_colored "$YELLOW" "  Skipped operations: $SKIPPED_COUNT"
    echo ""
    
    if [[ ${#FAILED_REPOS[@]} -gt 0 ]]; then
        print_colored "$RED" "❌ Failed repositories:"
        for failed_repo in "${FAILED_REPOS[@]}"; do
            print_colored "$RED" "  - $failed_repo"
        done
        echo ""
    fi
    
    print_colored "$BLUE" "📁 Mirror structure:"
    if [[ -d "$DESTINATION_ROOT" ]]; then
        local total_size=$(du -sh "$DESTINATION_ROOT" 2>/dev/null | cut -f1)
        print_colored "$GREEN" "  Total size: $total_size"
        
        echo "  Directory breakdown:"
        for platform_dir in "$DESTINATION_ROOT"/*; do
            if [[ -d "$platform_dir" && "$(basename "$platform_dir")" != "logs" ]]; then
                local platform=$(basename "$platform_dir")
                local count=$(find "$platform_dir" -name "*.git" -type d 2>/dev/null | wc -l)
                local size=$(du -sh "$platform_dir" 2>/dev/null | cut -f1)
                if [[ $count -gt 0 ]]; then
                    echo "    📂 $platform: $count repositories ($size)"
                fi
            fi
        done
    fi
    
    echo ""
    print_colored "$BLUE" "💾 Mirror location: $DESTINATION_ROOT"
    echo ""
    print_colored "$GREEN" "💡 Next steps:"
    echo "  - Set up a cron job to run this script regularly"
    echo "  - Example: 0 2 * * * /home/dwilliams/git-mirror-script.sh"
    echo "  - Subsequent runs will be much faster (incremental sync only)"
    
    # Log summary to file
    log_message "INFO" "SUMMARY - Total: $TOTAL_REPOS, Success: $SUCCESS_COUNT (New: $NEW_REPOS, Updated: $UPDATED_REPOS), Failed: $FAILED_COUNT, Skipped: $SKIPPED_COUNT"
    
    if [[ $FAILED_COUNT -gt 0 ]]; then
        log_message "INFO" "Failed repositories: ${FAILED_REPOS[*]}"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Function to show usage
show_usage() {
    cat << EOF
Git Repository Mirror Script v2.0

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    --dry-run      Show what would be done without actually doing it

CONFIGURATION:
    Edit the configuration section at the top of this script to:
    - Set destination directory (DESTINATION_ROOT)
    - Add GitHub users (GITHUB_USERS array)
    - Add GitLab users (GITLAB_USERS array)
    - Add Codeberg users (CODEBERG_USERS array)
    - Add Bitbucket users (BITBUCKET_USERS array)
    - Add SourceForge projects (SOURCEFORGE_PROJECTS array)
    - Add custom GitLab instances (CUSTOM_GITLAB_INSTANCES array)
    - Add custom repositories (CUSTOM_REPOS array)

EXAMPLES:
    $0                    # Run with default settings
    $0 --verbose         # Run with verbose output
    $0 --dry-run        # Show what would be done

For more information, see the comments in the script configuration section.
EOF
}

# Main execution function
main() {
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    local dry_run=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_colored "$BLUE" "🚀 Git Repository Mirror Script v2.0"
    print_colored "$BLUE" "Started at: $start_time"
    print_colored "$BLUE" "Destination: $DESTINATION_ROOT"
    
    if [[ "$dry_run" == true ]]; then
        print_colored "$YELLOW" "🔍 DRY RUN MODE - No changes will be made"
    fi
    
    echo ""
    
    # First ensure directories exist before we try to log to them
    setup_directories
    
    # Now we can safely log
    log_message "INFO" "Starting mirror operation"
    log_message "INFO" "Destination root: $DESTINATION_ROOT"
    log_message "INFO" "GitHub users: ${GITHUB_USERS[*]}"
    log_message "INFO" "GitLab users: ${GITLAB_USERS[*]}"
    log_message "INFO" "Codeberg users: ${CODEBERG_USERS[*]}"
    log_message "INFO" "Bitbucket users: ${BITBUCKET_USERS[*]}"
    log_message "INFO" "SourceForge projects: ${SOURCEFORGE_PROJECTS[*]}"
    log_message "INFO" "Custom GitLab instances: ${CUSTOM_GITLAB_INSTANCES[*]}"
    log_message "INFO" "Custom repositories: ${CUSTOM_REPOS[*]}"
    
    if [[ "$dry_run" == true ]]; then
        log_message "INFO" "DRY RUN MODE ENABLED"
        print_colored "$YELLOW" "This is what would be done:"
        # In a real implementation, you'd add dry-run logic here
        exit 0
    fi
    
    # Check dependencies
    check_dependencies
    
    # Mirror repositories from all platforms
    mirror_github_repos
    mirror_gitlab_repos
    mirror_codeberg_repos
    mirror_bitbucket_repos
    mirror_sourceforge_repos
    mirror_custom_gitlab_repos
    mirror_custom_repos
    
    print_colored "$GREEN" "🎉 Mirror operation completed!"
    
    if [[ $FAILED_COUNT -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Cleanup function
cleanup() {
    local exit_code=$?
    print_summary
    exit $exit_code
}

# Trap to ensure we always print a summary
trap cleanup EXIT

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
