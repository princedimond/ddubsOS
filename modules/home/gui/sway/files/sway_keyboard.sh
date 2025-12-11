#!/bin/bash

# Detect layout
SYSTEM_LAYOUT=$(localectl status | grep "VC Keymap" | awk '{print $3}')

if [[ -z "$SYSTEM_LAYOUT" || "$SYSTEM_LAYOUT" == "(unset)" ]]; then
    SYSTEM_LAYOUT="us"
fi

# Apply layout live instead of writing to managed files
swaymsg input "type:keyboard" xkb_layout "$SYSTEM_LAYOUT"

# Reload Sway to apply changes if needed
swaymsg reload
