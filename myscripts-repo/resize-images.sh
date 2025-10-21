#!/usr/bin/env -S nix shell nixpkgs#libwebp nixpkgs#libnotify -c bash
set -euo pipefail

# resize-images.sh
# - Converts images to WebP with resizing and quality settings
# - Suppresses tool output and shows a simple progress bar across files
# - Sends a desktop notification on completion (or when errors occurred)

# Defaults (can be overridden by flags or env vars)
SRC_DIR=${SRC_DIR:-wallpapers}
OUT_DIR=${OUT_DIR:-wallpapers/optimized}
MAXH=${MAXH:-1080}            # Max height (Keeps aspect). Use 0 to keep original height
QUALITY=${QUALITY:-75}        # WebP quality (0-100)
EXTS=${EXTS:-jpg,jpeg,png,JPG,JPEG,PNG}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]
Options:
  -s DIR   Source directory (default: ${SRC_DIR})
  -d DIR   Destination directory (default: ${OUT_DIR})
  -H N     Max height in pixels (default: ${MAXH})
  -q N     Quality percent for WebP (0-100, default: ${QUALITY})
  -e LIST  Comma-separated extensions (default: ${EXTS})
  -h       Show this help
Environment overrides:
  SRC_DIR, OUT_DIR, MAXH, QUALITY, EXTS
EOF
}

while getopts ":s:d:H:q:e:h" opt; do
  case "$opt" in
    s) SRC_DIR="$OPTARG";;
    d) OUT_DIR="$OPTARG";;
    H) MAXH="$OPTARG";;
    q) QUALITY="$OPTARG";;
    e) EXTS="$OPTARG";;
    h) usage; exit 0;;
    :) echo "Missing argument for -$OPTARG" >&2; usage; exit 2;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2;;
  esac
done

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    # title, body
    notify-send -a "resize-images" "$1" "$2"
  fi
}

mkdir -p "$OUT_DIR"

# Gather files
shopt -s nullglob
IFS=, read -r -a _exts <<<"$EXTS"
files=()
for ext in "${_exts[@]}"; do
  for f in "$SRC_DIR"/*."$ext"; do
    files+=("$f")
  done
done
shopt -u nullglob

total=${#files[@]}
if [[ "$total" -eq 0 ]]; then
  echo "No source images found in $SRC_DIR (extensions: $EXTS)"
  notify "Resize images: nothing to do" "$SRC_DIR has no matching files"
  exit 0
fi

bar_width=40
progress_bar() {
  local i="$1"; local tot="$2"; local width="$3"
  local perc=$(( (i * 100) / tot ))
  local filled=$(( (i * width) / tot ))
  local empty=$(( width - filled ))
  printf "\rProcessing %d of %d [" "$i" "$tot"
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s-" $(seq 1 $empty)
  printf "] %3d%%" "$perc"
}

errors=0
idx=0

for f in "${files[@]}"; do
  idx=$((idx + 1))
  base="$(basename -- "$f")"
  stem="${base%.*}"
  out="$OUT_DIR/${stem}.webp"

  # Skip if up-to-date
  if [[ -f "$out" && "$out" -nt "$f" ]]; then
    progress_bar "$idx" "$total" "$bar_width"
    continue
  fi

  # Convert (quiet); suppress tool output
  if ! cwebp -quiet -q "$QUALITY" -m 6 -af -mt -resize 0 "$MAXH" "$f" -o "$out" >/dev/null 2>&1; then
    errors=$((errors + 1))
  fi
  progress_bar "$idx" "$total" "$bar_width"
done
printf "\n"

if [[ "$errors" -gt 0 ]]; then
  echo "Completed with $errors error(s) out of $total files."
  notify "Images resized with errors" "$errors of $total failed"
  exit 1
else
  echo "Completed successfully: $total image(s) processed."
  notify "Images resized" "$total processed to $OUT_DIR"
fi
