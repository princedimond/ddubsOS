#!/usr/bin/env bash
# Print JSON for a given workspace number: text = N, class = empty|occupied[ focused]
set -euo pipefail

n="$1"
ws_list=$(swaymsg -t get_workspaces)
focused=false
occupied=false

# Focused if workspace with this num is focused in the list
if echo "$ws_list" | jq -e --argjson n "$n" 'map(select(.num == $n and .focused == true)) | length > 0' >/dev/null; then
  focused=true
fi

# Occupied if the tree shows any nodes or floating_nodes under this workspace
if swaymsg -t get_tree | jq -e --argjson n "$n" 'recurse(.nodes[]?, .floating_nodes[]?) | select(.type=="workspace" and .num==$n) | ((.nodes|length) + (.floating_nodes|length)) > 0' >/dev/null; then
  occupied=true
fi

cls="empty"
if $occupied; then
  cls="occupied"
fi
if $focused; then
  cls="$cls focused"
fi

printf '{"text":"%s","class":"%s"}\n' "$n" "$cls"
