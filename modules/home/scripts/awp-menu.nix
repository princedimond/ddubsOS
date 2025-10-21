{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "awp-menu";
  # Provide tools at runtime
  runtimeInputs = with pkgs; [
    rofi
    findutils
    coreutils
    gnugrep
    gnused
    openssl
    gawk
    ffmpegthumbnailer
  ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    DIR="''${WALLPAPERS_DIR:-$HOME/Pictures/Wallpapers}"
    SIZE="''${AWP_THUMB_SIZE:-200}"
    CACHE="''${AWP_CACHE_DIR:-$HOME/.cache/vidthumbs}"

    if [[ ! -d "''${DIR}" ]]; then
      echo "Directory not found: ''${DIR}" >&2
      exit 1
    fi

    mkdir -p "''${CACHE}"

    # Gather supported video files (common formats supported by mpv/mpvpaper)
    # Use absolute paths and follow symlinks
    mapfile -t FILES < <(
      find -L "''${DIR}" -maxdepth 1 \( -type f -o -type l \) \
        \( -iname '*.mp4' -o -iname '*.m4v' -o -iname '*.mp4v' -o \
           -iname '*.mov' -o -iname '*.webm' -o -iname '*.avi' -o \
           -iname '*.mkv' -o -iname '*.mpeg' -o -iname '*.mpg' -o \
           -iname '*.wmv' -o -iname '*.avchd' -o -iname '*.flv' -o \
           -iname '*.ogv' -o -iname '*.m2ts' -o -iname '*.ts' -o \
           -iname '*.3gp' \) \
        -print0 | tr '\0' '\n' | sort -f
    )

    if [[ "''${#FILES[@]}" -eq 0 ]]; then
      echo "No video wallpapers found in ''${DIR}" >&2
      exit 1
    fi

    # Build status header for rofi (with markup)
    if pgrep -x mpvpaper >/dev/null 2>&1 || pgrep -f '(^|/)mpvpaper( |$)' >/dev/null 2>&1; then
      STATUS_LINE="<span foreground='#22c55e'>MPVPaper status: ACTIVE</span>    [ Enter to toggle ]"
    else
      STATUS_LINE="<span foreground='#ef4444'>MPVPaper status: INACTIVE</span>"
    fi

    # Prepare menu with thumbnails and stripped extensions
    MENU_FILE=$(mktemp)
    for path in "''${FILES[@]}"; do
      base=$(basename """$path""")
      label="''${base%.*}"
      # hash from absolute path for stable cache key
      hash=$(printf "%s" """$path""" | openssl dgst -sha256 -r | awk '{print $1}')
      thumb="''${CACHE}/''${hash}.png"
      if [[ ! -f "''${thumb}" ]]; then
        # Create a thumbnail using ffmpegthumbnailer (fast, picks a representative frame)
        ffmpegthumbnailer -i """$path""" -o """$thumb""" -s "''${SIZE}" -q 8 || true
      fi
      printf "%s\x00icon\x1f%s\n" """$label""" """$thumb""" >> "''${MENU_FILE}"
    done

    # Invoke rofi: header first (no icon), then items with icons
    sel_index=$( {
      printf '%s\n' "''${STATUS_LINE}"
      cat "''${MENU_FILE}"
    } | rofi -dmenu -i -matching fuzzy -markup-rows -show-icons -p 'awp' \
         -theme-str 'window { width: 140ch; height: 50%; border-radius: 12px; border: 2px; padding: 12px; background-color: rgba(24, 24, 27, 0.82); } inputbar { margin: 0 0 10px 0; } listview { lines: 20; background-color: transparent; } entry { background-color: rgba(0, 0, 0, 0.2); } element { background-color: transparent; padding: 6px 10px; } element selected { background-color: rgba(255, 255, 255, 0.10); }' \
         -format i ) || true

    # Exit if user canceled
    [[ -z "''${sel_index:-}" ]] && exit 0

    # Header is index 0
    if [[ "''${sel_index}" == "0" ]]; then
      if pgrep -x mpvpaper >/dev/null 2>&1 || pgrep -f '(^|/)mpvpaper( |$)' >/dev/null 2>&1; then
        awp --kill >/dev/null 2>&1 || true
        for _ in {1..50}; do
          if ! pgrep -x mpvpaper >/dev/null 2>&1 && ! pgrep -f '(^|/)mpvpaper( |$)' >/dev/null 2>&1; then
            break
          fi
          sleep 0.1
        done
      fi
      exec "$0"
    fi

    # Adjust index to map into FILES array
    idx=$(( sel_index - 1 ))
    if [[ "''${idx}" -lt 0 || "''${idx}" -ge "''${#FILES[@]}" ]]; then
      exit 1
    fi

    path="''${FILES[$idx]}"
    if [[ ! -f "''${path}" ]]; then
      echo "Selected file missing: ''${path}" >&2
      exit 1
    fi

    if ! command -v awp >/dev/null 2>&1; then
      echo "awp not found in PATH. Ensure it is installed via Home Manager." >&2
      exit 127
    fi

    # replace any running mpvpaper instances to avoid duplicates
    awp --kill >/dev/null 2>&1 || true

    exec awp -f "''${path}" -m all --stretch
  '';
}
