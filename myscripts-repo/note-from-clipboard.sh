#!/usr/bin/env bash

# Check if required commands are available
check_dependencies() {
  local missing_deps=()
  
  if ! command -v wl-paste >/dev/null 2>&1; then
    missing_deps+=("wl-clipboard")
  fi
  
  if ! command -v notify-send >/dev/null 2>&1; then
    missing_deps+=("libnotify")
  fi
  
  if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "Error: Missing required dependencies: ${missing_deps[*]}" >&2
    echo "Please install the missing packages:" >&2
    echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}" >&2
    echo "  Fedora: sudo dnf install ${missing_deps[*]}" >&2
    echo "  Arch: sudo pacman -S ${missing_deps[*]}" >&2
    exit 1
  fi
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTE_SCRIPT="$SCRIPT_DIR/note.sh"

# Check if note.sh exists
if [ ! -f "$NOTE_SCRIPT" ]; then
  echo "Error: note.sh not found in the same directory as this script" >&2
  echo "Expected location: $NOTE_SCRIPT" >&2
  exit 1
fi

# Make sure note.sh is executable
chmod +x "$NOTE_SCRIPT"

# Check dependencies
check_dependencies

# Check clipboard content type
clipboard_type=$(wl-paste --list-types | head -n 1)

if [[ "$clipboard_type" == "text/plain"* ]]; then
  # It's text, let's create a note
  wl-paste | "$NOTE_SCRIPT"
  if [ $? -eq 0 ]; then
    notify-send -t 3000 "📝 Note Created" "Clipboard content added as a new note."
  else
    notify-send -t 5000 -u critical "❌ Note Creation Failed" "There was an error creating the note."
  fi
else
  # It's not text, so we do nothing and notify the user
  notify-send -t 4000 -u low "📋 Note Skipped" "Clipboard does not contain text."
fi
