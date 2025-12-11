#!/usr/bin/env bash
# Doom Emacs feature module for zcli
# Provides: zcli doom [upgrade|status|start|stop|restart]

doom_main() {
  # Drop primary if present
  if [ "${1-}" = "doom" ]; then shift; fi
  if [ "$#" -lt 1 ]; then
    echo "Error: doom command requires a subcommand." >&2
    echo "Usage: zcli doom [upgrade|status|start|stop|restart|logs]" >&2
    return 1
  fi

  local sub="$1"
  shift || true

  local EMACSDIR="$HOME/.emacs.d"
  local DOOM_BIN="$EMACSDIR/bin/doom"
  local SYSTEMCTL="systemctl --user"

  case "$sub" in
    status)
      echo "Doom/Emacs Status:"
      echo "=================="
      if [ -x "$DOOM_BIN" ]; then
        echo "✔ Doom CLI found: $DOOM_BIN"
        # Try to get doom version (non-fatal if it fails)
        if ver=$("$DOOM_BIN" --version 2>/dev/null); then
          echo "  $ver"
        fi
      else
        echo "✗ Doom CLI not found at $DOOM_BIN"
        echo "  Hint: run 'get-doom' or 'zcli doom upgrade' after installing Doom."
      fi
      # Emacs daemon status (report transitional states)
      state=$($SYSTEMCTL is-active emacs 2>/dev/null || true)
      case "$state" in
        active)
          echo "✔ Emacs daemon is running (systemd user service 'emacs')"
          ;;
        activating)
          echo "… Emacs daemon is starting (activating)"
          ;;
        deactivating)
          echo "… Emacs daemon is stopping (deactivating)"
          ;;
        failed)
          echo "✗ Emacs daemon failed to start"
          echo "  Check details with: systemctl --user status emacs --no-pager"
          ;;
        inactive|*)
          echo "✗ Emacs daemon is not running"
          echo "  Start it with: zcli doom start"
          ;;
      esac
      ;;

    start)
      echo "Starting Emacs user daemon..."
      if $SYSTEMCTL start emacs 2>/dev/null; then
        echo "✔ Emacs daemon started"
      else
        echo "Error: failed to start Emacs daemon. Try: systemctl --user status emacs" >&2
        return 1
      fi
      ;;

    stop)
      echo "Stopping Emacs user daemon..."
      if $SYSTEMCTL stop emacs 2>/dev/null; then
        echo "✔ Emacs daemon stopped"
      else
        echo "Error: failed to stop Emacs daemon. Try: systemctl --user status emacs" >&2
        return 1
      fi
      ;;

    restart)
      echo "Restarting Emacs user daemon..."
      if $SYSTEMCTL restart emacs 2>/dev/null; then
        echo "✔ Emacs daemon restarted"
      else
        # Fallback: stop then start to provide a nicer message
        $SYSTEMCTL stop emacs 2>/dev/null || true
        if $SYSTEMCTL start emacs 2>/dev/null; then
          echo "✔ Emacs daemon restarted"
        else
          echo "Error: failed to restart Emacs daemon. Try: systemctl --user status emacs" >&2
          return 1
        fi
      fi
      ;;

    upgrade)
      if [ ! -x "$DOOM_BIN" ]; then
        echo "Error: Doom CLI not found at $DOOM_BIN" >&2
        echo "First-time install steps:" >&2
        echo "  1) git clone --depth 1 https://github.com/doomemacs/doomemacs \"$EMACSDIR\"" >&2
        echo "  2) \"$EMACSDIR/bin/doom\" install" >&2
        echo "Then re-run: zcli doom upgrade" >&2
        return 1
      fi
      echo "Stopping Emacs daemon (if running) before upgrade..."
      $SYSTEMCTL stop emacs 2>/dev/null || true
      echo "Running: doom upgrade"
      if "$DOOM_BIN" upgrade; then
        echo "✔ Doom upgrade complete"
      else
        echo "Error: doom upgrade failed" >&2
        return 1
      fi
      echo "Starting Emacs daemon..."
      $SYSTEMCTL start emacs 2>/dev/null || true
      ;;

    logs)
      # Usage: zcli doom logs [-n N] [--follow|-f]
      local count=200
      local follow=""
      while [ "$#" -gt 0 ]; do
        case "$1" in
          -n)
            shift
            if [ -n "${1-}" ]; then
              case "$1" in
                (*[!0-9]*|"") : ;; # ignore non-numeric
                (*) count="$1" ;;
              esac
              shift || true
            fi
            ;;
          --follow|-f)
            follow="--follow"
            shift
            ;;
          *)
            break
            ;;
        esac
      done
      echo "Showing Emacs daemon logs (last $count lines)..."
      if command -v journalctl >/dev/null 2>&1; then
        journalctl --user -u emacs --no-pager -n "$count" $follow
      else
        echo "Error: journalctl not found." >&2
        return 1
      fi
      ;;

    *)
      echo "Error: Invalid doom subcommand '$sub'" >&2
      echo "Usage: zcli doom [upgrade|status|start|stop|restart|logs]" >&2
      return 1
      ;;
  esac
}
