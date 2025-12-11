#!/usr/bin/env bash

# Colors and icons for nice output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SUCCESS_ICON="✅"
ERROR_ICON="❌"
WARNING_ICON="⚠️"
INFO_ICON="ℹ️"

# Source directory variable
SOURCE_DIR="${HOME}/ddubsos"

# Function to print colored messages
print_success() {
    echo -e "${GREEN}${SUCCESS_ICON} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR_ICON} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING_ICON} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO_ICON} $1${NC}"
}

# Parse command line arguments
DRY_RUN=false

# Check for dry-run flag
if [[ "$1" == "--dry-run" || "$1" == "-n" ]]; then
    DRY_RUN=true
    shift
fi

# Check if correct number of arguments provided
if [ $# -ne 3 ]; then
    print_error "Usage: $0 [--dry-run|-n] <branch_name> <tag_name> <message_file>"
    print_info "Example: $0 feature-branch v1.0.0 /path/to/tag-message.txt"
    print_info "Example: $0 --dry-run feature-branch v1.0.0 /path/to/tag-message.txt"
    exit 1
fi

BRANCH_NAME="$1"
TAG_NAME="$2"
MSG_FILE_RAW="$3"

# Preserve the original working directory at invocation time
ORIG_PWD="$(pwd)"

# Resolve message file to an absolute path before changing directories
case "$MSG_FILE_RAW" in
  ~/*) MSG_FILE="${HOME}/${MSG_FILE_RAW#~/}" ;;
  *) MSG_FILE="$MSG_FILE_RAW" ;;
esac

# If the path is relative, make it absolute relative to the original cwd
if [[ "$MSG_FILE" != /* ]]; then
  MSG_FILE="${ORIG_PWD%/}/$MSG_FILE"
fi

# Normalize the path if readlink -f is available
if command -v readlink >/dev/null 2>&1; then
  RESOLVED="$(readlink -f -- "$MSG_FILE" 2>/dev/null)" || RESOLVED="$MSG_FILE"
  MSG_FILE="$RESOLVED"
fi

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE: No actual changes will be made"
fi

print_info "Branch: $BRANCH_NAME"
print_info "Tag: $TAG_NAME"
print_info "Message file: $MSG_FILE"
print_info "Source directory: $SOURCE_DIR"

# Change to source directory
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory '$SOURCE_DIR' does not exist!"
    exit 1
fi

cd "$SOURCE_DIR" || {
    print_error "Failed to change to source directory '$SOURCE_DIR'"
    exit 1
}

# Verify we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Directory '$SOURCE_DIR' is not a git repository!"
    exit 1
fi

# Check if message file exists and is a text file
if [ ! -f "$MSG_FILE" ]; then
    print_error "Message file '$MSG_FILE' does not exist!"
    exit 1
fi

# Check if file is a text file
if ! file "$MSG_FILE" | grep -q "text"; then
    print_error "Message file '$MSG_FILE' is not a text file!"
    exit 1
fi

# Check if message file is readable and not empty
if [ ! -r "$MSG_FILE" ]; then
    print_error "Message file '$MSG_FILE' is not readable!"
    exit 1
fi

if [ ! -s "$MSG_FILE" ]; then
    print_error "Message file '$MSG_FILE' is empty!"
    exit 1
fi

# In dry-run mode, show a preview of the message file content
if [ "$DRY_RUN" = true ]; then
    print_info "Message file content preview:"
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────${NC}"
    while IFS= read -r line; do
        echo -e "${BLUE}│${NC} $line"
    done < "$MSG_FILE"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────${NC}"
fi

# Check if branch already exists (locally and remotely)
BRANCH_EXISTS_LOCAL=false
BRANCH_EXISTS_REMOTE=false

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    BRANCH_EXISTS_LOCAL=true
fi

if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    BRANCH_EXISTS_REMOTE=true
fi

if [ "$BRANCH_EXISTS_LOCAL" = true ]; then
    print_warning "Branch '$BRANCH_NAME' already exists locally."
    if [ "$DRY_RUN" = false ]; then
        read -r -p "Create tag '$TAG_NAME' on existing branch '$BRANCH_NAME'? [y/N] " RESP_USE_EXISTING
        case "$RESP_USE_EXISTING" in
            [Yy]*)
                print_info "Proceeding with existing branch '$BRANCH_NAME'"
                ;;
            *)
                print_info "Operation cancelled by user."
                exit 0
                ;;
        esac
    else
        print_info "DRY RUN: Would prompt to create tag on existing branch"
    fi
elif [ "$BRANCH_EXISTS_REMOTE" = true ]; then
    print_warning "Branch '$BRANCH_NAME' exists on remote."
    if [ "$DRY_RUN" = false ]; then
        read -r -p "Create local tracking branch and tag '$TAG_NAME'? [y/N] " RESP_USE_REMOTE
        case "$RESP_USE_REMOTE" in
            [Yy]*)
                print_info "Proceeding with remote branch '$BRANCH_NAME'"
                ;;
            *)
                print_info "Operation cancelled by user."
                exit 0
                ;;
        esac
    else
        print_info "DRY RUN: Would prompt to create local tracking branch and tag"
    fi
fi

# Check if tag already exists (locally and remotely)
if git rev-parse -q --verify "refs/tags/$TAG_NAME" >/dev/null; then
    print_error "Tag '$TAG_NAME' already exists locally!"
    exit 1
fi

if git ls-remote --tags origin | grep -q "refs/tags/$TAG_NAME"; then
    print_error "Tag '$TAG_NAME' already exists on remote!"
    exit 1
fi

print_info "All validations passed. Preparing branch and tag..."

# Prepare or create the branch
CREATED_NEW_BRANCH=false
if [ "$BRANCH_EXISTS_LOCAL" = true ]; then
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would checkout existing branch '$BRANCH_NAME'"
    else
        if git checkout "$BRANCH_NAME"; then
            print_success "Checked out existing branch '$BRANCH_NAME'"
        else
            print_error "Failed to checkout existing branch '$BRANCH_NAME'"
            exit 1
        fi
    fi
elif [ "$BRANCH_EXISTS_REMOTE" = true ]; then
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would fetch and create local tracking branch '$BRANCH_NAME' from 'origin/$BRANCH_NAME'"
    else
        if git fetch origin && git checkout -B "$BRANCH_NAME" "origin/$BRANCH_NAME"; then
            print_success "Created local tracking branch '$BRANCH_NAME' from 'origin/$BRANCH_NAME'"
        else
            print_error "Failed to create local tracking branch '$BRANCH_NAME'"
            exit 1
        fi
    fi
else
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would create branch '$BRANCH_NAME'"
        CREATED_NEW_BRANCH=true
    else
        if git checkout -b "$BRANCH_NAME"; then
            print_success "Created branch '$BRANCH_NAME'"
            CREATED_NEW_BRANCH=true
        else
            print_error "Failed to create branch '$BRANCH_NAME'"
            exit 1
        fi
    fi
fi

# Create the tag
if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN: Would create tag '$TAG_NAME' with message from '$MSG_FILE'"
    print_success "DRY RUN: Branch '$BRANCH_NAME' and tag '$TAG_NAME' would be created successfully!"
else
    if git tag -a "$TAG_NAME" -F "$MSG_FILE"; then
        print_success "Created tag '$TAG_NAME' with message from '$MSG_FILE'"
        print_success "Branch '$BRANCH_NAME' and tag '$TAG_NAME' created successfully!"
    else
        print_error "Failed to create tag '$TAG_NAME'"
        # Clean up: delete the branch we just created (if we created it here)
        if [ "$CREATED_NEW_BRANCH" = true ]; then
            git checkout - >/dev/null 2>&1
            git branch -d "$BRANCH_NAME" >/dev/null 2>&1
            print_warning "Cleaned up branch '$BRANCH_NAME' due to tag creation failure"
        fi
        exit 1
    fi
fi

# Prompt to push branch and tag to remote
if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN: Would push branch '$BRANCH_NAME' to 'origin' (git push -u origin \"$BRANCH_NAME\")"
    print_warning "DRY RUN: Would push tag '$TAG_NAME' to 'origin' (git push origin \"$TAG_NAME\")"
else
    # Ask to push branch
    read -r -p "Push branch '$BRANCH_NAME' to 'origin'? [y/N] " RESP_PUSH_BRANCH
    case "$RESP_PUSH_BRANCH" in
        [Yy]*)
            if git push -u origin "$BRANCH_NAME"; then
                print_success "Pushed branch '$BRANCH_NAME' to 'origin'"
            else
                print_error "Failed to push branch '$BRANCH_NAME' to 'origin'"
            fi
            ;;
        *)
            print_info "Skipping branch push."
            ;;
    esac

    # Ask to push tag
    read -r -p "Push tag '$TAG_NAME' to 'origin'? [y/N] " RESP_PUSH_TAG
    case "$RESP_PUSH_TAG" in
        [Yy]*)
            if git push origin "$TAG_NAME"; then
                print_success "Pushed tag '$TAG_NAME' to 'origin'"
            else
                print_error "Failed to push tag '$TAG_NAME' to 'origin'"
            fi
            ;;
        *)
            print_info "Skipping tag push."
            ;;
    esac
fi
