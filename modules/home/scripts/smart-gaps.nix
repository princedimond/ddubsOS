{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "smart-gaps";
  # Runtime dependencies for Hyprland smart gaps functionality
  runtimeInputs = with pkgs; [
    jq        # JSON parsing
    libnotify # notify-send
  ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Smart gaps for Hyprland - toggles workspace-specific visual settings
    # Similar to i3's smart_gaps feature, removes gaps/borders when they'd be redundant

    # Configuration - you can customize these values
    SMART_GAPS_IN=0
    SMART_GAPS_OUT=0  
    SMART_ROUNDING=0
    SMART_BORDER_SIZE=0
    NOTIFICATION_TIMEOUT=1500
    HYPRCTL_PATH="/etc/profiles/per-user/dwilliams/bin/hyprctl"

    # Function to show usage
    usage() {
      cat <<'EOF'
    Usage: smart-gaps [OPTIONS]
    
    Toggle smart gaps for the current Hyprland workspace.
    When enabled, removes gaps, rounding, and borders for a cleaner look.
    When disabled, restores default Hyprland settings.

    Options:
      -h, --help     Show this help message
      -q, --quiet    Don't show notifications
      --gaps-in N    Set inner gaps when smart gaps is on (default: 0)
      --gaps-out N   Set outer gaps when smart gaps is on (default: 0)
      --rounding N   Set rounding when smart gaps is on (default: 0)
      --border N     Set border size when smart gaps is on (default: 0)

    Environment:
      SMART_GAPS_IN      Override default inner gaps (default: 0)
      SMART_GAPS_OUT     Override default outer gaps (default: 0) 
      SMART_ROUNDING     Override default rounding (default: 0)
      SMART_BORDER_SIZE  Override default border size (default: 0)
    EOF
    }

    # Parse command line arguments
    QUIET=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        -q|--quiet)
          QUIET=true
          shift
          ;;
        --gaps-in)
          [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
          SMART_GAPS_IN="$2"
          shift 2
          ;;
        --gaps-out)
          [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
          SMART_GAPS_OUT="$2" 
          shift 2
          ;;
        --rounding)
          [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
          SMART_ROUNDING="$2"
          shift 2
          ;;
        --border)
          [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
          SMART_BORDER_SIZE="$2"
          shift 2
          ;;
        *)
          echo "Unknown argument: $1" >&2
          usage
          exit 2
          ;;
      esac
    done

    # Override with environment variables if set
    SMART_GAPS_IN=''${SMART_GAPS_IN:-0}
    SMART_GAPS_OUT=''${SMART_GAPS_OUT:-0}
    SMART_ROUNDING=''${SMART_ROUNDING:-0}
    SMART_BORDER_SIZE=''${SMART_BORDER_SIZE:-0}

    # Function to send notifications (if not quiet)
    notify() {
      if [[ "$QUIET" == "false" ]] && command -v notify-send >/dev/null 2>&1; then
        notify-send -t "$NOTIFICATION_TIMEOUT" "Smart-gaps" "$1"
      fi
    }

    # Function to get current workspace ID
    get_workspace_id() {
      if ! command -v "$HYPRCTL_PATH" >/dev/null 2>&1; then
        echo "Error: hyprctl not found. Are you running Hyprland?" >&2
        exit 127
      fi

      local workspace_info
      if ! workspace_info=$("$HYPRCTL_PATH" -j activeworkspace 2>/dev/null); then
        echo "Error: Failed to get active workspace from hyprctl" >&2
        exit 1
      fi

      local workspace_id
      if ! workspace_id=$(echo "$workspace_info" | jq -r '.id' 2>/dev/null); then
        echo "Error: Failed to parse workspace ID from JSON" >&2
        exit 1
      fi

      if [[ "$workspace_id" == "null" ]] || [[ -z "$workspace_id" ]]; then
        echo "Error: Could not determine current workspace ID" >&2
        exit 1
      fi

      echo "$workspace_id"
    }

    # Function to check if smart gaps are currently active by comparing current gap values
    is_smart_gaps_active() {
      # Check if current gaps match our smart gaps values
      local current_gaps_in
      local current_gaps_out
      local current_rounding
      
      current_gaps_in=$("$HYPRCTL_PATH" getoption general:gaps_in | grep "custom type:" | awk '{print $3}')
      current_gaps_out=$("$HYPRCTL_PATH" getoption general:gaps_out | grep "custom type:" | awk '{print $3}')
      current_rounding=$("$HYPRCTL_PATH" getoption decoration:rounding | grep "int:" | awk '{print $2}')
      
      # Smart gaps is active if current values match our smart gaps settings
      [[ "$current_gaps_in" == "$SMART_GAPS_IN" ]] && \
      [[ "$current_gaps_out" == "$SMART_GAPS_OUT" ]] && \
      [[ "$current_rounding" == "$SMART_ROUNDING" ]]
    }


    # Function to apply smart gaps
    apply_smart_gaps() {
      local workspace_id="$1"
      
      echo "Applying smart gaps to workspace $workspace_id..." >&2

      # Store current values before applying smart gaps
      local current_gaps_in current_gaps_out current_rounding current_border
      current_gaps_in=$("$HYPRCTL_PATH" getoption general:gaps_in | grep "custom type:" | awk '{print $3}')
      current_gaps_out=$("$HYPRCTL_PATH" getoption general:gaps_out | grep "custom type:" | awk '{print $3}')
      current_rounding=$("$HYPRCTL_PATH" getoption decoration:rounding | grep "int:" | awk '{print $2}')
      current_border=$("$HYPRCTL_PATH" getoption general:border_size | grep "int:" | awk '{print $2}')
      
      # Store original values in a temp file for restoration
      echo "$current_gaps_in $current_gaps_out $current_rounding $current_border" > "/tmp/smart-gaps-original-$workspace_id"

      # Apply smart gaps settings directly
      "$HYPRCTL_PATH" keyword general:gaps_in "$SMART_GAPS_IN" >/dev/null
      "$HYPRCTL_PATH" keyword general:gaps_out "$SMART_GAPS_OUT" >/dev/null  
      "$HYPRCTL_PATH" keyword decoration:rounding "$SMART_ROUNDING" >/dev/null
      "$HYPRCTL_PATH" keyword general:border_size "$SMART_BORDER_SIZE" >/dev/null

      notify "Smart gaps enabled"
      return 0
    }

    # Function to remove smart gaps (restore defaults)
    remove_smart_gaps() {
      local workspace_id="$1"
      
      echo "Removing smart gaps from workspace $workspace_id..." >&2

      # Try to restore from saved values first
      local restore_file="/tmp/smart-gaps-original-$workspace_id"
      if [[ -f "$restore_file" ]]; then
        local original_values
        original_values=$(cat "$restore_file")
        local orig_gaps_in orig_gaps_out orig_rounding orig_border
        read -r orig_gaps_in orig_gaps_out orig_rounding orig_border <<< "$original_values"
        
        "$HYPRCTL_PATH" keyword general:gaps_in "$orig_gaps_in" >/dev/null
        "$HYPRCTL_PATH" keyword general:gaps_out "$orig_gaps_out" >/dev/null
        "$HYPRCTL_PATH" keyword decoration:rounding "$orig_rounding" >/dev/null
        "$HYPRCTL_PATH" keyword general:border_size "$orig_border" >/dev/null
        
        # Clean up temp file
        rm -f "$restore_file"
      else
        # Fallback to config reload if no saved values
        "$HYPRCTL_PATH" reload >/dev/null
      fi

      notify "Smart gaps disabled"
      return 0
    }

    # Main execution
    main() {
      # Get current workspace
      local workspace_id
      workspace_id=$(get_workspace_id)
      
      echo "Current workspace: $workspace_id" >&2

      # Check current state and toggle
      if is_smart_gaps_active; then
        echo "Smart gaps are currently active, disabling..." >&2
        remove_smart_gaps "$workspace_id"
      else
        echo "Smart gaps are not active, enabling..." >&2  
        apply_smart_gaps "$workspace_id"
      fi
    }

    # Run main function
    main "$@"
  '';
}