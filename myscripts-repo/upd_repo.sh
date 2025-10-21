#!/bin/bash

# This script updates all git repositories in a specified subdirectory of a base directory.
# It's designed to be run from a cron job or manually.

# The base directory where all repository collections are stored.
BASE_DIR="/mnt/nas/config.files/Git-Mirror"
VERBOSE=false

# --- Helper Functions ---

# Log a message only if VERBOSE is true.
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

# --- Script Body ---

# Parse command-line arguments
if [ "$1" = "--verbose" ]; then
    VERBOSE=true
    shift # Remove --verbose from the argument list
fi

# Check if the user provided a subdirectory name.
if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") [--verbose] <subdirectory>"
    echo "Example: $(basename "$0") --verbose jak"
    exit 1
fi

SUBDIR="$1"
SOURCE_DIR="$BASE_DIR/$SUBDIR"

# Check if the constructed source directory exists.
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Directory not found: $SOURCE_DIR"
    exit 1
fi

log_verbose "============================================="
log_verbose "Starting repository updates in: $SOURCE_DIR"
log_verbose "$(date)"
log_verbose "============================================="

# Find all directories inside the source directory and loop through them.
find "$SOURCE_DIR" -maxdepth 1 -mindepth 1 -type d | while read -r repo_path; do
    # Check if the directory is a git repository.
    if [ -d "$repo_path/.git" ]; then
        repo_name=$(basename "$repo_path")
        log_verbose "--- Updating repository: $repo_name ---"
        
        # Change into the repository directory.
        # Using a subshell to avoid `cd` affecting the main script's CWD.
        (
            cd "$repo_path" || exit
            
            log_verbose "Pulling latest changes..."
            # The output of git pull will be shown regardless of the verbose flag.
            git pull
        )
        
        log_verbose "--- Finished $repo_name ---"
        log_verbose ""
    else
        log_verbose "--- Skipping $(basename "$repo_path") (not a git repository) ---"
        log_verbose ""
    fi
done

log_verbose "============================================="
log_verbose "All updates complete."
log_verbose "$(date)"
log_verbose "============================================="
