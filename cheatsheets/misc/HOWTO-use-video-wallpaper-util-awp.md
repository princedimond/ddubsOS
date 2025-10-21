# How to use the Animated Wallpaper utility (awp)

This guide explains how to use the animated wallpaper tools included in ddubsOS:
- awp: a CLI wrapper around mpvpaper that sets animated wallpapers per monitor or all monitors
- awp-menu: a compact, searchable rofi menu to pick a wallpaper file and apply it with awp

Requirements
- mpvpaper installed and in PATH
- Wayland compositor (Hyprland, sway, etc.)
- jq (for monitor detection via hyprctl/swaymsg), provided at runtime by the package

Wallpaper directory
- Default directory: ~/Pictures/Wallpapers
- Override via environment variable: WALLPAPERS_DIR

Quick start
- Set a specific file on all monitors:
  ```bash path=null start=null
  awp -f "$HOME/Pictures/Wallpapers/Animated-Space-Room-2.mp4" -m all
  ```
- Pick from a menu and apply (defaults to stretch to fill):
  ```bash path=null start=null
  awp-menu
  ```

CLI: awp
Usage
```bash path=null start=null
awp [1|2|3...] [-f|--file FILE] [-m|--mon MONITOR|all] [--fill|--stretch] [-k|--kill]
```
- -f, --file FILE: path to a wallpaper (video or animated image)
- -m, --mon MON: select a monitor name (e.g., HDMI-A-1) or all
  - If omitted: awp tries the focused monitor, then falls back to the first detected
- --fill: crop-fill to screen (preserve aspect) via mpv panscan=1.0
- --stretch: stretch to fill the screen (ignore aspect) via mpv keepaspect=no
- -k, --kill: terminate existing mpvpaper instance(s)
  - With -m MON, kills only that monitor’s mpvpaper
  - Without -m, kills all mpvpaper processes

Examples
- Stretch to fill on all monitors:
  ```bash path=null start=null
  awp -f "$HOME/Pictures/Wallpapers/foo.avif" -m all --stretch
  ```
- Crop-fill (preserve aspect, may crop edges) on one monitor:
  ```bash path=null start=null
  awp -f "$HOME/Pictures/Wallpapers/bar.mkv" -m HDMI-A-1 --fill
  ```
- Replace whatever is running with the selected wallpaper:
  ```bash path=null start=null
  awp --kill && awp -f "$HOME/Pictures/Wallpapers/clip.webm" -m all
  ```

Notes
- awp forwards mpv options to mpvpaper via -o under the hood. By default, awp always enables loop.
- --fill adds panscan=1.0; --stretch adds keepaspect=no.

Menu: awp-menu
- Lists common mpv/mpvpaper-supported formats in your wallpapers directory, including:
  MP4, M4V, MP4V, MOV, WEBM, AVI, MKV, MPEG/MPG, WMV, AVCHD, FLV, OGV, M2TS/TS, 3GP, and AVIF.
- Includes symlinks in the top-level directory.
- Uses rofi with fuzzy, case-insensitive search.
- Styling: rounded corners and translucent background to support blur/shadow.
- Behavior: calls awp with --stretch by default (loop, keepaspect=no) so narrow media fills the screen.

Examples
- Open the menu and apply selection to all monitors:
  ```bash path=null start=null
  awp-menu
  ```
- Use a different directory just for this run:
  ```bash path=null start=null
  WALLPAPERS_DIR="$HOME/Videos/Wallpapers" awp-menu
  ```

Troubleshooting
- No files listed in menu
  - Confirm the directory exists: echo "$WALLPAPERS_DIR" (or default path)
  - Confirm files are top-level (awp-menu uses -maxdepth 1)
  - If your files are symlinks, they are supported
- Wallpaper doesn’t fill screen
  - Use --stretch for full screen (may distort aspect)
  - Use --fill to preserve aspect and crop edges
- Multiple mpvpaper instances
  - Use awp --kill to terminate existing instances
  - awp-menu already clears existing mpvpaper processes before applying

Integration tips
- Bind a key to launch awp-menu in your compositor (e.g., Hyprland binds)
- If you frequently prefer crop-fill, you can add --fill to your keybinding or alias

Security and safety
- awp and awp-menu are non-privileged user utilities
- No secrets are used; avoid placing secrets in filenames/paths

Where the scripts live
- awp: modules/home/scripts/awp.nix (installed as an executable)
- awp-menu: modules/home/scripts/awp-menu.nix (installed as an executable)

Happy customizing!

