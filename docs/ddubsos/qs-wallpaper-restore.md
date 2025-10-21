# qs-wallpapers-restore

Restore the last selected wallpaper at session startup, with robust fallbacks and Hyprpanel-safe swww startup.

Installed from: modules/home/scripts/qs-wallpapers-restore.nix

## What it does

- Reads the last applied wallpaper from state files written by qs-wallpapers-apply:
  - $XDG_STATE_HOME/qs-wallpapers/current.json (preferred)
  - $XDG_STATE_HOME/qs-wallpapers/current_wallpaper (fallback)
- Applies the wallpaper using a prioritized order:
  1) The backend that was used when it was saved (if recorded)
  2) swww
  3) hyprpaper
  4) mpvpaper
  5) waypaper (as a soft fallback; failures are ignored and next is tried)
- Manages conflicts by stopping incompatible daemons between attempts (e.g., stops mpvpaper/hyprpaper before using swww, stops swww/hyprpaper before using mpvpaper).
- If using swww, waits for Hyprpanel (if present) before starting swww-daemon to avoid race conditions with panel startup. If Waybar is already running, it proceeds immediately.

## Where state is stored

These files are written by qs-wallpapers-apply whenever a selection is successfully applied:

- $XDG_STATE_HOME/qs-wallpapers/current.json
  - path: absolute path to the image
  - backend: mpvpaper | swww | hyprpaper
  - timestamp: seconds since epoch
- $XDG_STATE_HOME/qs-wallpapers/current_wallpaper
  - Plain text with the same absolute image path. Used as a simple fallback if JSON is missing.

## Hyprland integration

Hyprland exec-once is configured to run qs-wallpapers-restore. The configuration wires in a default fallback via waypaper if there is no saved state or restore fails.

- For hyprpanel setups (primary): Hyprpanel starts first, then qs-wallpapers-restore. The script waits briefly for Hyprpanel before starting swww-daemon.
- For waybar setups: swww-daemon starts early; qs-wallpapers-restore runs afterward and applies via swww or falls back.

See modules/home/hyprland/exec-once.nix for the exact lines.

## Options (environment variables)

- QS_RESTORE_WAIT_HYPRPANEL_SECONDS
  - Default: 15
  - Seconds to wait for the `hyprpanel` process before starting swww-daemon. If not detected within this window, the script proceeds anyway.
- QS_RESTORE_ORDER
  - Default order (after recorded backend): swww,hyprpaper,mpvpaper,waypaper
  - Provide a comma-separated list to override, e.g.: `QS_RESTORE_ORDER="hyprpaper,swww,mpvpaper"`
- QS_DEBUG
  - If set, enables verbose logging (prefixed with [qs-restore]).

## Exit behavior

- Returns 0 on success (wallpaper applied via any method).
- Returns 1 if all methods failed.
- Returns 0 and exits quickly if no valid saved path exists (allowing exec-once to proceed to its fallback, e.g., a default image via waypaper).

## Notes and caveats

- waypaper is treated as a soft fallback: if it fails (e.g., after a Python update), the script simply continues to the next method or exits.
- No X11-only tools (e.g., nitrogen) are used. Wayland-native tools are preferred.
- The default application backend for new selections is controlled by `WALLPAPER_BACKEND` (see qs-wallpapers-apply docs).
