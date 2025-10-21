#!/usr/bin/env bash
set -euo pipefail

# Author: Don Williams (ddubs)
# 
# Approximate Sum total system uptime based on `last` reboot entries (+ current uptime)
# Notes:
# - Only `reboot   system boot ...` lines are considered; user sessions are ignored.
# - The current boot is accounted for using /proc/uptime.
# - Forces base-10 arithmetic to avoid octal interpretation of leading zeros.

# Options
JSON=0
since_override=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      JSON=1; shift ;;
    --since)
      [[ $# -ge 2 ]] || { echo "--since requires a date" >&2; exit 1; }; since_override="$2"; shift 2 ;;
    --since=*)
      since_override="${1#--since=}"; shift ;;
    -h|--help)
      echo "Usage: $0 [--json] [--since DATE]"; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2; echo "Usage: $0 [--json] [--since DATE]" >&2; exit 1 ;;
  esac
done

now_epoch=$(date +%s)

total_seconds=0

# Oldest reboot start (from the last reboot line in wtmp) unless overridden
if [[ -n "$since_override" ]]; then
  oldest_start="$since_override"
else
  oldest_start=$(last --time-format=full \
    | awk '/^reboot[[:space:]]+system[[:space:]]+boot/ {last=$0} END { \
        if (last) { \
          gsub(/^.*system[[:space:]]+boot[[:space:]]+[^[:space:]]+[[:space:]]+/, "", last); \
          sub(/[[:space:]]+-.*$/, "", last); \
          sub(/[[:space:]]+still[[:space:]]+running.*$/, "", last); \
          print last \
        } \
      }')
fi

# Format the oldest start nicely (e.g., Thursday, May 24, 2025)
since_pretty="${oldest_start}"
if command -v date >/dev/null 2>&1 && [[ -n "${oldest_start}" ]]; then
  since_pretty=$(date -d "${oldest_start}" '+%A, %B %-d, %Y' 2>/dev/null || printf '%s' "${oldest_start}")
fi

# Heuristics to determine OS installation date
os_installed=""
# 1) Try root filesystem birth time (if supported)
root_birth=$(stat -c '%w' / 2>/dev/null || true)
if [[ -n "${root_birth}" && "${root_birth}" != "-" ]]; then
  os_installed=$(date -d "${root_birth}" '+%A, %B %-d, %Y at %H:%M:%S' 2>/dev/null || printf '%s' "${root_birth}")
fi
# 2) On Arch/CachyOS, fall back to first pacman.log entry
if [[ -z "${os_installed}" && -f /var/log/pacman.log ]]; then
  first_pacman_ts=$(sed -n '1s/^\[\([^]]\+\)\].*/\1/p' /var/log/pacman.log)
  if [[ -n "${first_pacman_ts}" ]]; then
    os_installed=$(date -d "${first_pacman_ts}" '+%A, %B %-d, %Y at %H:%M:%S' 2>/dev/null || printf '%s' "${first_pacman_ts}")
  fi
fi
# 3) Fallback to oldest reboot start (best-effort lower bound)
if [[ -z "${os_installed}" && -n "${oldest_start}" ]]; then
  os_installed=$(date -d "${oldest_start}" '+%A, %B %-d, %Y at %H:%M:%S' 2>/dev/null || printf '%s' "${oldest_start}")
fi

while IFS= read -r line; do
  # Consider only system boot records
  [[ $line == reboot* ]] || continue

  # If this is the current boot, sum from its start to now
  if [[ $line == *"still running"* ]]; then
    # Extract the start timestamp fields (everything after kernel field up to "still running")
    start_str=$(sed -E 's/^reboot[[:space:]]+system[[:space:]]+boot[[:space:]]+\S+[[:space:]]+//; s/[[:space:]]+still[[:space:]]+running.*$//' <<<"$line")
    if [[ -n "$start_str" ]]; then
      start_epoch=$(date -d "$start_str" +%s 2>/dev/null || echo "")
      if [[ -n "$start_epoch" ]]; then
        total_seconds=$(( total_seconds + (now_epoch - start_epoch) ))
      fi
    fi
    continue
  fi

  # Extract duration in parentheses at end: either D+HH:MM or HH:MM
  if [[ $line =~ \(([0-9]+)\+([0-9]{1,2}):([0-9]{2})\)[[:space:]]*$ ]]; then
    days=${BASH_REMATCH[1]}
    hours=${BASH_REMATCH[2]}
    minutes=${BASH_REMATCH[3]}
  elif [[ $line =~ \(([0-9]{1,2}):([0-9]{2})\)[[:space:]]*$ ]]; then
    days=0
    hours=${BASH_REMATCH[1]}
    minutes=${BASH_REMATCH[2]}
  else
    # No parsable duration; skip
    continue
  fi

  # Force base-10 to avoid octal interpretation of leading zeros
  session_seconds=$(( (10#$days * 86400) + (10#$hours * 3600) + (10#$minutes * 60) ))
  total_seconds=$(( total_seconds + session_seconds ))
done < <(last --time-format=full)

# Convert total seconds to days, hours, and minutes
 days=$(( total_seconds / 86400 ))
 seconds_left=$(( total_seconds % 86400 ))
 hours=$(( seconds_left / 3600 ))
 minutes=$(( (seconds_left % 3600) / 60 ))

if [[ $JSON -eq 1 ]]; then
  # Emit JSON
  # Escape strings minimally for JSON
  esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
  printf '{"os_installed":"%s","since":"%s","total_seconds":%d,"days":%d,"hours":%d,"minutes":%d}\n' \
    "$(esc "${os_installed}")" "$(esc "${since_pretty}")" "$total_seconds" "$days" "$hours" "$minutes"
else
  if [[ -n "${os_installed}" ]]; then
    printf "OS installed: %s\n" "$os_installed"
  fi
  printf "Total uptime since %s\n" "$since_pretty"
  printf "%d days, %d hours, %d minutes\n" "$days" "$hours" "$minutes"
fi
