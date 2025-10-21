#!/bin/bash

# Enhanced Git Repository Mirror Script v3.0
# Creates both bare mirrors (for backup) AND working copies (for browsing/using code)
# Mirrors multiple repositories from various Git hosting platforms
# Supports GitHub, GitLab, Codeberg, Bitbucket, SourceForge, and custom Git servers
# Provides comprehensive logging and statistics

set -euo pipefail

# ============================================================================
# CONFIGURATION - EDIT THESE VARIABLES AS NEEDED
# ============================================================================

# Set desired destination root - exit with error if not available
DESTINATION_ROOT="/mnt/nas/config.files/GitRepoMirror"

# Check if the designated destination root is available
if [[ ! -d "$DESTINATION_ROOT" ]]; then
    # If destination doesn't exist, check if parent is writable
    if [[ ! -d "$(dirname "$DESTINATION_ROOT")" || ! -w "$(dirname "$DESTINATION_ROOT")" ]]; then
        echo "❌ ERROR: Designated destination root parent is not available or not writable"
        echo "   Specified path: $DESTINATION_ROOT"
        echo "   Parent directory: $(dirname "$DESTINATION_ROOT")"
        echo "   Please ensure the storage location is properly mounted and accessible."
        exit 1
    fi
else
    # If destination exists, check if it's writable
    if [[ ! -w "$DESTINATION_ROOT" ]]; then
        echo "❌ ERROR: Designated destination root is not writable"
        echo "   Specified path: $DESTINATION_ROOT"
        echo "   Please ensure you have write permissions."
        exit 1
    fi
fi

LOG_DIR="${DESTINATION_ROOT}/logs"
# LOG_FILE will be set after directories are created

# New configuration for working copies
CREATE_WORKING_COPIES=true  # Set to false if you only want bare mirrors
WORKING_COPIES_ROOT="${DESTINATION_ROOT}/working-copies"  # Where to put browsable code

# ============================================================================
# REPOSITORY CONFIGURATION (Same as your original script)
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
    "dwilliam62" 
    "zaney"
    "thelinuxcast"
    "Alxhr0"
    "garuda-linux"
    "paridhips"
)

# Codeberg repositories - will fetch all repos for each user
CODEBERG_USERS=(
    "ranjan"
)

# Bitbucket repositories - will fetch all repos for each user
BITBUCKET_USERS=(
    # Add Bitbucket usernames here
)

# SourceForge projects
SOURCEFORGE_PROJECTS=(
    # Add SourceForge project names here
)

# Custom GitLab instances (self-hosted)
CUSTOM_GITLAB_INSTANCES=(
    # Examples: "https://gitlab.example.com:myusername"
)

# Custom Git repositories (any Git URL)
CUSTOM_REPOS=(
    # Examples: "my-project:https://git.example.com/user/project.git"
)

# Repositories to exclude from mirroring
EXCLUDED_REPOS=(
    "github/iynaix/nixpkgs"  # Very large fork of nixpkgs (5GB+)
    "github/fufexan/nixpkgs"  # Very large fork of nixpkgs (5GB+)
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
NEW_WORKING_COPIES=0
UPDATED_WORKING_COPIES=0
FAILED_REPOS=()

# Timeout for API calls (seconds)
API_TIMEOUT=60

# Timeout for git operations (seconds)
GIT_UPDATE_TIMEOUT=300   # 5 minutes for updates
GIT_CLONE_TIMEOUT=1800   # 30 minutes for initial clones of large repos

# Maximum concurrent operations
MAX_PARALLEL_JOBS=8

# ============================================================================
# UTILITY FUNCTIONS (Same as original)
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
    
    # Add working copies directories if enabled
    if [[ "$CREATE_WORKING_COPIES" == true ]]; then
        dirs+=(
            "$WORKING_COPIES_ROOT"
            "$WORKING_COPIES_ROOT/github"
            "$WORKING_COPIES_ROOT/gitlab"
            "$WORKING_COPIES_ROOT/codeberg"
            "$WORKING_COPIES_ROOT/bitbucket"
            "$WORKING_COPIES_ROOT/sourceforge"
            "$WORKING_COPIES_ROOT/custom-gitlab"
            "$WORKING_COPIES_ROOT/custom"
        )
    fi
    
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
    log_message "INFO" "Working copies enabled: $CREATE_WORKING_COPIES"
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
# NEW WORKING COPY FUNCTIONS
# ============================================================================

# Function to create or update a working copy from a bare repository
create_or_update_working_copy() {
    local bare_repo_path="$1"
    local working_copy_path="$2"
    local display_name="$3"
    
    if [[ ! -d "$bare_repo_path" ]]; then
        log_message "WARNING" "Bare repository not found for working copy: $bare_repo_path"
        return 1
    fi
    
    # Save current directory
    local original_dir=$(pwd)
    
    if [[ -d "$working_copy_path" ]]; then
        # Update existing working copy
        log_message "INFO" "Updating working copy: $working_copy_path"
        
        # Check if it's actually a git repository
        if [[ ! -d "$working_copy_path/.git" ]]; then
            log_message "WARNING" "Working copy path exists but is not a git repository, removing: $working_copy_path"
            rm -rf "$working_copy_path"
            # Fallback to creating new working copy
            create_or_update_working_copy "$bare_repo_path" "$working_copy_path" "$display_name"
            return $?
        fi
        
        cd "$working_copy_path" || {
            log_message "ERROR" "Failed to enter working copy directory: $working_copy_path"
            cd "$original_dir"
            return 1
        }
        
        # Check if the remote origin exists and points to the right place
        local current_origin
        current_origin=$(git config --get remote.origin.url 2>/dev/null || echo "")
        if [[ "$current_origin" != "$bare_repo_path" ]]; then
            log_message "INFO" "Updating remote origin URL for working copy: $display_name"
            git remote set-url origin "$bare_repo_path" 2>/dev/null || {
                log_message "WARNING" "Failed to update remote URL, recreating working copy: $display_name"
                cd "$original_dir"
                rm -rf "$working_copy_path"
                create_or_update_working_copy "$bare_repo_path" "$working_copy_path" "$display_name"
                return $?
            }
        fi
        
        # Try to fetch updates with timeout and better error handling
        if timeout 120 git fetch --all --prune 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
            # Get current branch
            local current_branch
            current_branch=$(git branch --show-current 2>/dev/null || echo "")
            
            # If we're on a branch, try to update it
            if [[ -n "$current_branch" ]] && git show-ref --verify --quiet "refs/remotes/origin/$current_branch"; then
                if git merge "origin/$current_branch" --ff-only 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                    log_message "SUCCESS" "Updated working copy: $display_name"
                    print_colored "$GREEN" "📝 Updated working copy: $display_name"
                    UPDATED_WORKING_COPIES=$((UPDATED_WORKING_COPIES + 1))
                else
                    log_message "WARNING" "Could not fast-forward working copy (local changes?): $display_name"
                    print_colored "$YELLOW" "⚠️  Working copy has local changes: $display_name"
                fi
            else
                log_message "INFO" "Working copy not on a trackable branch: $display_name"
                print_colored "$CYAN" "ℹ️  Working copy updated (detached HEAD): $display_name"
            fi
        else
            log_message "ERROR" "Failed to update working copy: $display_name"
            print_colored "$RED" "❌ Failed to update working copy: $display_name"
            
            # If fetch failed, consider recreating the working copy
            log_message "INFO" "Attempting to recreate working copy due to fetch failure: $display_name"
            cd "$original_dir"
            rm -rf "$working_copy_path"
            create_or_update_working_copy "$bare_repo_path" "$working_copy_path" "$display_name"
            return $?
        fi
    else
        # Create new working copy
        log_message "INFO" "Creating new working copy: $working_copy_path"
        
        # Create parent directory if needed
        mkdir -p "$(dirname "$working_copy_path")" || {
            log_message "ERROR" "Failed to create parent directory for working copy: $working_copy_path"
            cd "$original_dir"
            return 1
        }
        
        # Clone from the bare repository with timeout
        if timeout 300 git clone "$bare_repo_path" "$working_copy_path" 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
            cd "$working_copy_path" || {
                log_message "ERROR" "Failed to enter newly created working copy: $working_copy_path"
                cd "$original_dir"
                return 1
            }
            
            # Set up remote to point to the bare repository for future updates
            git remote set-url origin "$bare_repo_path" 2>/dev/null || {
                log_message "WARNING" "Failed to set remote URL for working copy: $display_name"
            }
            
            # Get the default branch and check it out
            local default_branch
            default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
            
            # If default branch doesn't exist, try common alternatives
            if ! git show-ref --verify --quiet "refs/remotes/origin/$default_branch"; then
                for branch in main master develop; do
                    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
                        default_branch="$branch"
                        break
                    fi
                done
            fi
            
            # Check out the default branch if it exists
            if git show-ref --verify --quiet "refs/remotes/origin/$default_branch"; then
                git checkout -B "$default_branch" "origin/$default_branch" 2>/dev/null || true
            fi
            
            log_message "SUCCESS" "Created new working copy: $display_name"
            print_colored "$GREEN" "📝 New working copy: $display_name"
            NEW_WORKING_COPIES=$((NEW_WORKING_COPIES + 1))
        else
            log_message "ERROR" "Failed to create working copy: $display_name"
            print_colored "$RED" "❌ Failed to create working copy: $display_name"
            # Clean up failed clone attempt
            [[ -d "$working_copy_path" ]] && rm -rf "$working_copy_path"
            cd "$original_dir"
            return 1
        fi
    fi
    
    # Always return to original directory
    cd "$original_dir"
    return 0
}

# ============================================================================
# API FUNCTIONS (Same as original script - keeping them for completeness)
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
            
            # Check if we got an error response (like 404 User Not Found)
            if grep -q '"message":' "$temp_file"; then
                local error_msg=$(grep -o '"message":"[^"]*"' "$temp_file" | cut -d'"' -f4)
                log_message "WARNING" "GitLab API error for user $username: $error_msg - trying as group instead"
                rm -f "$temp_file"
                # Try as a group instead
                get_gitlab_group_repos "$username" "$gitlab_url"
                return $?
            fi
            
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

# Function to get all repositories for a GitLab group
get_gitlab_group_repos() {
    local groupname="$1"
    local gitlab_url="${2:-https://gitlab.com}"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for GitLab group: $groupname at $gitlab_url"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "$gitlab_url/api/v4/groups/$groupname/projects?per_page=100&page=$page" > "$temp_file"; then
            
            # Check if we got an error response
            if grep -q '"message":' "$temp_file"; then
                local error_msg=$(grep -o '"message":"[^"]*"' "$temp_file" | cut -d'"' -f4)
                log_message "ERROR" "GitLab API error for group $groupname: $error_msg"
                rm -f "$temp_file"
                return 1
            fi
            
            local repos_on_page
            if command -v jq >/dev/null 2>&1; then
                repos_on_page=$(jq -r '.[].path' "$temp_file" 2>/dev/null || echo "")
            else
                repos_on_page=$(extract_json_field "$temp_file" "path")
            fi
            
            # If no repos on this page, we're done
            if [[ -z "$repos_on_page" ]]; then
                break
            fi
            
            all_repos="$all_repos$repos_on_page"$'\n'
            ((page++))
        else
            log_message "ERROR" "Failed to fetch repositories for GitLab group: $groupname"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# Function to get all repositories for a Codeberg user (uses Gitea/Forgejo API)
get_codeberg_user_repos() {
    local username="$1"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for Codeberg user: $username"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "https://codeberg.org/api/v1/users/$username/repos?limit=100&page=$page" > "$temp_file"; then
            
            # Check if we got an error response
            if grep -q '"message":' "$temp_file"; then
                local error_msg=$(grep -o '"message":"[^"]*"' "$temp_file" | cut -d'"' -f4)
                log_message "ERROR" "Codeberg API error for user $username: $error_msg"
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
            log_message "ERROR" "Failed to fetch repositories for Codeberg user: $username (page $page)"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# ============================================================================
# ENHANCED MIRROR FUNCTIONS
# ============================================================================

# Enhanced function to mirror a single repository (now also creates working copies)
mirror_repository() {
    local repo_url="$1"
    local local_path="$2"
    local display_name="${3:-$(basename "$repo_url" .git)}"
    local platform="${4:-unknown}"
    
    log_message "INFO" "Starting mirror for: $display_name ($platform)"
    print_colored "$BLUE" "🔄 Processing: $display_name"
    
    TOTAL_REPOS=$((TOTAL_REPOS + 1))
    
    # First, handle the bare repository (mirror) - same logic as original
    local mirror_success=false
    
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
            mirror_success=true
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
            mirror_success=true
            
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
    
    # Now handle working copy if mirrors were successful and working copies are enabled
    if [[ "$mirror_success" == true && "$CREATE_WORKING_COPIES" == true ]]; then
        # Determine working copy path based on the mirror path
        local working_copy_path
        working_copy_path=$(echo "$local_path" | sed "s|$DESTINATION_ROOT|$WORKING_COPIES_ROOT|" | sed 's/\.git$//')
        
        create_or_update_working_copy "$local_path" "$working_copy_path" "$display_name"
    fi
}

# ============================================================================
# PLATFORM-SPECIFIC MIRROR FUNCTIONS (Same as original, using enhanced mirror_repository)
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
            done <<<"$repos"
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
                
                # Check if repository is excluded
                if is_repo_excluded "codeberg" "$username" "$repo_name"; then
                    log_message "INFO" "Skipping excluded repository: codeberg/$username/$repo_name"
                    print_colored "$YELLOW" "⏭️  Skipped (excluded): $username/$repo_name"
                    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                    continue
                fi
                
                local repo_url="https://codeberg.org/$username/$repo_name.git"
                local local_path="$DESTINATION_ROOT/codeberg/$username/$repo_name.git"
                
                mirror_repository "$repo_url" "$local_path" "$username/$repo_name" "Codeberg"
            done <<<"$repos"
        else
            log_message "ERROR" "Failed to get repository list for Codeberg user: $username"
            print_colored "$RED" "❌ Failed to fetch repos for: $username"
            FAILED_REPOS+=("$username (Codeberg user repos fetch failed)")
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    done
}

# ============================================================================
# ENHANCED SUMMARY AND REPORTING
# ============================================================================

# Enhanced function to print summary
print_summary() {
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    print_colored "$BLUE" "="*80
    print_colored "$BLUE" "📊 ENHANCED MIRROR OPERATION SUMMARY"
    print_colored "$BLUE" "="*80
    
    echo "Completed at: $end_time"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "📈 Statistics:"
    print_colored "$BLUE" "  Total repositories processed: $TOTAL_REPOS"
    print_colored "$GREEN" "  Successful mirror operations: $SUCCESS_COUNT"
    print_colored "$CYAN" "    ├─ New mirrors: $NEW_REPOS"
    print_colored "$CYAN" "    └─ Updated mirrors: $UPDATED_REPOS"
    
    if [[ "$CREATE_WORKING_COPIES" == true ]]; then
        print_colored "$GREEN" "  Working copy operations:"
        print_colored "$CYAN" "    ├─ New working copies: $NEW_WORKING_COPIES"
        print_colored "$CYAN" "    └─ Updated working copies: $UPDATED_WORKING_COPIES"
    fi
    
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
            if [[ -d "$platform_dir" && "$(basename "$platform_dir")" != "logs" && "$(basename "$platform_dir")" != "working-copies" ]]; then
                local platform=$(basename "$platform_dir")
                local count=$(find "$platform_dir" -name "*.git" -type d 2>/dev/null | wc -l)
                local size=$(du -sh "$platform_dir" 2>/dev/null | cut -f1)
                if [[ $count -gt 0 ]]; then
                    echo "    📂 $platform: $count repositories ($size)"
                fi
            fi
        done
        
        if [[ "$CREATE_WORKING_COPIES" == true && -d "$WORKING_COPIES_ROOT" ]]; then
            local working_copies_size=$(du -sh "$WORKING_COPIES_ROOT" 2>/dev/null | cut -f1)
            local working_copies_count=$(find "$WORKING_COPIES_ROOT" -maxdepth 3 -type d -name "*" 2>/dev/null | grep -v "\.git" | wc -l)
            echo "    📝 Working copies: $working_copies_count repositories ($working_copies_size)"
        fi
    fi
    
    echo ""
    print_colored "$BLUE" "💾 Storage locations:"
    print_colored "$GREEN" "  📁 Bare mirrors (backup): $DESTINATION_ROOT"
    if [[ "$CREATE_WORKING_COPIES" == true ]]; then
        print_colored "$GREEN" "  📝 Working copies (browsable): $WORKING_COPIES_ROOT"
    fi
    echo ""
    
    print_colored "$GREEN" "💡 Usage tips:"
    echo "  📁 Browse code: cd $WORKING_COPIES_ROOT/github/username/repo"
    echo "  🔄 Clone from mirror: git clone $DESTINATION_ROOT/github/username/repo.git"
    echo "  📋 List all repos: find $WORKING_COPIES_ROOT -maxdepth 3 -type d -name '*' | grep -v .git"
    echo "  🕒 Set up cron job: 0 2 * * * $0"
    
    # Log summary to file
    log_message "INFO" "SUMMARY - Total: $TOTAL_REPOS, Success: $SUCCESS_COUNT (New: $NEW_REPOS, Updated: $UPDATED_REPOS), Failed: $FAILED_COUNT, Skipped: $SKIPPED_COUNT"
    if [[ "$CREATE_WORKING_COPIES" == true ]]; then
        log_message "INFO" "Working copies - New: $NEW_WORKING_COPIES, Updated: $UPDATED_WORKING_COPIES"
    fi
    
    if [[ $FAILED_COUNT -gt 0 ]]; then
        log_message "INFO" "Failed repositories: ${FAILED_REPOS[*]}"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Function to show usage
show_usage() {
    cat <<EOF
Enhanced Git Repository Mirror Script v3.0

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    --dry-run          Show what would be done without actually doing it
    --mirrors-only     Create only bare mirrors (no working copies)
    --working-only     Update only working copies (skip mirror sync)

FEATURES:
    ✅ Creates bare mirrors for efficient backup/sync
    ✅ Creates browsable working copies for code review
    ✅ Supports incremental updates (only downloads changes)
    ✅ Preserves archived repositories
    ✅ Multi-platform support (GitHub, GitLab, etc.)

DIRECTORY STRUCTURE:
    📁 $DESTINATION_ROOT/
    ├── 📁 github/user/repo.git (bare mirrors)
    ├── 📁 gitlab/user/repo.git
    └── 📁 working-copies/
        ├── 📁 github/user/repo (browsable code)
        └── 📁 gitlab/user/repo

CONFIGURATION:
    Edit the configuration section at the top of this script to:
    - Set destination directory (DESTINATION_ROOT)
    - Add platform users (GITHUB_USERS, GITLAB_USERS, etc.)
    - Configure working copies (CREATE_WORKING_COPIES)

EXAMPLES:
    $0                      # Full sync (mirrors + working copies)
    $0 --mirrors-only       # Only update mirrors
    $0 --working-only       # Only update working copies
    $0 --dry-run           # Show what would be done

For more information, see the comments in the script configuration section.
EOF
}

# Main execution function
main() {
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    local dry_run=false
    local verbose=false
    local mirrors_only=false
    local working_only=false
    
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
            --mirrors-only)
                mirrors_only=true
                CREATE_WORKING_COPIES=false
                shift
                ;;
            --working-only)
                working_only=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_colored "$BLUE" "🚀 Enhanced Git Repository Mirror Script v3.0"
    print_colored "$BLUE" "Started at: $start_time"
    print_colored "$BLUE" "Destination: $DESTINATION_ROOT"
    
    if [[ "$CREATE_WORKING_COPIES" == true ]]; then
        print_colored "$BLUE" "Working copies: $WORKING_COPIES_ROOT"
    fi
    
    if [[ "$dry_run" == true ]]; then
        print_colored "$YELLOW" "🔍 DRY RUN MODE - No changes will be made"
    fi
    
    if [[ "$mirrors_only" == true ]]; then
        print_colored "$YELLOW" "🪞 MIRRORS ONLY - No working copies will be created"
    fi
    
    if [[ "$working_only" == true ]]; then
        print_colored "$YELLOW" "📝 WORKING COPIES ONLY - Mirrors will not be synced"
    fi
    
    echo ""
    
    # First ensure directories exist before we try to log to them
    setup_directories
    
    # Now we can safely log
    log_message "INFO" "Starting enhanced mirror operation"
    log_message "INFO" "Destination root: $DESTINATION_ROOT"
    log_message "INFO" "Working copies enabled: $CREATE_WORKING_COPIES"
    log_message "INFO" "Working copies root: $WORKING_COPIES_ROOT"
    log_message "INFO" "GitHub users: ${GITHUB_USERS[*]}"
    log_message "INFO" "GitLab users: ${GITLAB_USERS[*]}"
    
    if [[ "$dry_run" == true ]]; then
        log_message "INFO" "DRY RUN MODE ENABLED"
        print_colored "$YELLOW" "This is what would be done:"
        exit 0
    fi
    
    # Check dependencies
    check_dependencies
    
    # Handle different modes
    if [[ "$working_only" == true ]]; then
        print_colored "$YELLOW" "📝 Updating working copies only..."
        # Find existing mirrors and update their working copies
        find "$DESTINATION_ROOT" -name "*.git" -type d | while read -r mirror_path; do
            if [[ -d "$mirror_path" ]]; then
                local working_copy_path
                working_copy_path=$(echo "$mirror_path" | sed "s|$DESTINATION_ROOT|$WORKING_COPIES_ROOT|" | sed 's/\.git$//')
                local display_name=$(basename "$mirror_path" .git)
                create_or_update_working_copy "$mirror_path" "$working_copy_path" "$display_name"
            fi
        done
    else
        # Mirror repositories from all platforms (this will also create working copies if enabled)
        mirror_github_repos
        mirror_gitlab_repos
        mirror_codeberg_repos
        # Add other platforms as needed
    fi
    
    print_colored "$GREEN" "🎉 Enhanced mirror operation completed!"
    
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
