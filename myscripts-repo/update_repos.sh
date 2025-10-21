#!/bin/bash

#
# A script to update all git repositories in a specified directory.
# It's designed to be run from a cron job.
# This version also configures remotes to fetch Pull/Merge Requests.
# Use the -v or --verbose flag for interactive, verbose output.
#

# --- Configuration ---
# The directory containing the git repositories to update.
# IMPORTANT: Use an absolute path, especially for cron jobs.
# Example: SOURCE_DIR="/home/user/my_projects"
SOURCE_DIR="/mnt/nas/config.files/Git-Mirror/Jak"

# The file where logs will be stored.
# IMPORTANT: Use an absolute path.
LOG_FILE="${SOURCE_DIR}/repo_update.log"

# The maximum number of lines to keep in the log file.
MAX_LOG_LINES=120
# --- End of Configuration ---


# --- Argument Parsing ---
VERBOSE=false
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=true
fi
# --- End of Argument Parsing ---


# --- Script Logic ---
# Create a temporary file to store the log output for this specific run.
# This prevents partial logs if the script is interrupted.
RUN_LOG_TMP=$(mktemp)

# Function to log messages.
# It always writes to the log file.
# If VERBOSE is true, it also prints to the console.
log() {
    local message
    message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message" >> "$RUN_LOG_TMP"
    if [[ "$VERBOSE" == "true" ]]; then
        # Print the message without the timestamp for a cleaner interactive view.
        echo "$1"
    fi
}

log "===== Starting repository update run ====="

# Check if the source directory exists.
if [[ ! -d "$SOURCE_DIR" ]]; then
    log "ERROR: Source directory '$SOURCE_DIR' does not exist. Exiting."
    cat "$RUN_LOG_TMP" >> "$LOG_FILE"
    rm -f "$RUN_LOG_TMP"
    exit 1
fi

# Loop through each subdirectory in the source directory.
find "$SOURCE_DIR" -maxdepth 1 -mindepth 1 -type d | while read -r dir; do
    if [[ -d "$dir/.git" ]]; then
        log "Processing repository: $dir"
        cd "$dir" || { log "ERROR: Could not cd into $dir. Skipping."; continue; }

        # --- Configure Fetching for PRs/MRs ---
        REMOTE_URL=$(git config --get remote.origin.url)
        if [[ "$REMOTE_URL" == *"github.com"* ]]; then
            REF_SPEC="+refs/pull/*/head:refs/remotes/origin/pr/*"
            if ! git config --get-all remote.origin.fetch | grep -qF "$REF_SPEC"; then
                log "Adding GitHub PR fetch configuration to $dir"
                git config --add remote.origin.fetch "$REF_SPEC"
            fi
        elif [[ "$REMOTE_URL" == *"gitlab.com"* ]]; then
            REF_SPEC="+refs/merge-requests/*/head:refs/remotes/origin/mr/*"
            if ! git config --get-all remote.origin.fetch | grep -qF "$REF_SPEC"; then
                log "Adding GitLab MR fetch configuration to $dir"
                git config --add remote.origin.fetch "$REF_SPEC"
            fi
        fi
        # --- End of Configuration ---

        log "Updating repository: $dir"
        # Fetch all changes from all remotes.
        # --prune removes remote-tracking branches that no longer exist on the remote.
        if [[ "$VERBOSE" == "true" ]]; then
            # Show output on screen and append to log file.
            git remote update --prune 2>&1 | tee -a "$RUN_LOG_TMP"
        else
            # Only append to log file.
            git remote update --prune >> "$RUN_LOG_TMP" 2>&1
        fi
        
        if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
            log "Successfully updated: $dir"
        else
            log "WARNING: 'git remote update' failed for: $dir. See output above."
        fi
        log "----------------------------------------"
    else
        log "Skipping non-git directory: $dir"
        log "----------------------------------------"
    fi
done

log "===== Repository update run finished ====="
log "" # Add a blank line for readability.

# Append the log from this run to the main log file.
cat "$RUN_LOG_TMP" >> "$LOG_FILE"
rm -f "$RUN_LOG_TMP"

# Trim the main log file to the specified number of lines.
TRIM_TMP=$(mktemp)
tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$TRIM_TMP"
mv "$TRIM_TMP" "$LOG_FILE"

if [[ "$VERBOSE" == "true" ]]; then
    echo "Verbose run complete. Log saved to $LOG_FILE"
fi

exit 0
