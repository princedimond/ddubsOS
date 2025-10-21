{ pkgs }:
pkgs.writeShellScriptBin "rofi-wallpapers" ''
  #!/usr/bin/env bash
  set -euo pipefail

  # Defaults (configurable via env or flags)
  DIR="''${WALL_DIR:-$HOME/Pictures/Wallpapers}"
  COLS="''${WALL_COLS:-5}"
  ROWS="''${WALL_ROWS:-3}"
  SIZE="''${WALL_THUMB_SIZE:-200}"
  CACHE="''${WALL_CACHE_DIR:-$HOME/.cache/wallthumbs}"

  usage() {
    cat <<EOF
Usage: rofi-wallpapers [options]

Options:
  -d DIR   Wallpapers directory (default: $HOME/Pictures/Wallpapers)
  -c N     Columns (default: 5)
  -r N     Rows (default: 3)
  -s N     Thumb size in px (square) (default: 200)
  -t DIR   Thumbnail cache directory (default: $HOME/.cache/wallthumbs)
  -h       Show this help

Notes:
- Only image files are listed (jpg,jpeg,png,webp,avif,bmp,tiff). Videos are excluded.
- Thumbnails are cached and reused. Missing thumbs are created on-demand.
- Output: prints the absolute path of the selected wallpaper to stdout.
EOF
  }

  while getopts ":d:c:r:s:t:h" opt; do
    case "$opt" in
      d) DIR="$OPTARG" ;;
      c) COLS="$OPTARG" ;;
      r) ROWS="$OPTARG" ;;
      s) SIZE="$OPTARG" ;;
      t) CACHE="$OPTARG" ;;
      h) usage; exit 0 ;;
      :) echo "Missing argument for -$OPTARG" >&2; exit 2 ;;
      \?) echo "Unknown option -$OPTARG" >&2; usage; exit 2 ;;
    esac
  done

  if [ ! -d "$DIR" ]; then
    echo "Wallpapers directory not found: $DIR" >&2
    exit 1
  fi

  mkdir -p "$CACHE"

  # Collect images deterministically (no regex; use -iname patterns)
  mapfile -t IMAGES < <(${pkgs.findutils}/bin/find -L "$DIR" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' -o -iname '*.bmp' -o -iname '*.tiff' \) \
    -print0 | ${pkgs.coreutils}/bin/tr '\0' '\n' | ${pkgs.coreutils}/bin/sort)

  if [ "''${#IMAGES[@]}" -eq 0 ]; then
    echo "No images found in $DIR" >&2
    exit 1
  fi

  # Build menu with icons; ensure thumb exists for each
  MENU_FILE=$(mktemp)
  TRIMMED_LABELS=()

  for idx in "''${!IMAGES[@]}"; do
    img="''${IMAGES[$idx]}"
    # Stable thumb name from path hash
    hash=$(${pkgs.coreutils}/bin/printf "%s" "$img" | ${pkgs.openssl}/bin/openssl dgst -sha256 -r | ${pkgs.gawk}/bin/awk '{print $1}')
    thumb="$CACHE/$hash.png"

    if [ ! -f "$thumb" ]; then
      # Create square thumbnail (centered, padded)
      ${pkgs.imagemagick}/bin/convert "$img" -auto-orient -thumbnail "''${SIZE}x''${SIZE}>" \
        -background none -gravity center -extent "''${SIZE}x''${SIZE}" "$thumb" 2>/dev/null || true
    fi

    # Label (basename) but keep mapping by index
    label=$(${pkgs.coreutils}/bin/basename "$img")
    label_noext="''${label%.*}"
    TRIMMED_LABELS+=("$label_noext")
    # rofi script-mode line with icon metadata
    # Format: text\x00icon\x1f/path/to/icon.png\n
    printf "%s\x00icon\x1f%s\n" "$label_noext" "$thumb" >> "$MENU_FILE"
  done

  # Invoke rofi in dmenu mode with icons; capture index
  sel_index=$(ROFI_SYSTEM_THEME=1 rofi -dmenu -show-icons -columns "$COLS" -lines "$ROWS" -theme "$HOME/.config/rofi/wallpapers.rasi" -p "Wallpapers" -format i < "$MENU_FILE") || true

  # Rofi returns empty on cancel
  if [ -z "''${sel_index:-}" ]; then
    exit 1
  fi

  # Validate numeric index
  if ! [[ "$sel_index" =~ ^[0-9]+$ ]]; then
    echo "Invalid selection index from rofi: $sel_index" >&2
    exit 1
  fi

  if [ "$sel_index" -lt 0 ] || [ "$sel_index" -ge "''${#IMAGES[@]}" ]; then
    echo "Selection out of range" >&2
    exit 1
  fi

  printf "%s\n" "''${IMAGES[$sel_index]}"
''

