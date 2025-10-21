#!/usr/bin/env -S nix shell nixpkgs#ffmpeg nixpkgs#libnotify -c bash
set -euo pipefail

# resize-videos.sh
# - Re-encodes videos for wallpaper use (smaller size, no audio, loops nicely)
# - Suppresses ffmpeg output and shows a simple progress bar across files
# - Sends a desktop notification on completion (or when errors occurred)

# Defaults (can be overridden by flags or env vars)
SRC_DIR=${SRC_DIR:-wallpapers}
OUT_DIR=${OUT_DIR:-wallpapers/optimized}
HEIGHT=${HEIGHT:-1080}
FPS=${FPS:-30}
CODEC=${CODEC:-libx265}       # libx265 | libvpx-vp9 | libsvtav1
CRF=${CRF:-24}
PRESET=${PRESET:-slow}
DURATION=${DURATION:-}        # seconds cap, empty to keep full length

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]
Options:
  -s DIR   Source directory (default: ${SRC_DIR})
  -d DIR   Destination directory (default: ${OUT_DIR})
  -H N     Output height (default: ${HEIGHT})
  -F N     Output fps (default: ${FPS})
  -c CODEC Video codec: libx265 | libvpx-vp9 | libsvtav1 (default: ${CODEC})
  -r N     CRF/quality (default: ${CRF})
  -p NAME  Encoder preset (default: ${PRESET})
  -t SEC   Duration cap in seconds (optional)
  -h       Show this help
Environment overrides:
  SRC_DIR, OUT_DIR, HEIGHT, FPS, CODEC, CRF, PRESET, DURATION
EOF
}

while getopts ":s:d:H:F:c:r:p:t:h" opt; do
  case "$opt" in
    s) SRC_DIR="$OPTARG";;
    d) OUT_DIR="$OPTARG";;
    H) HEIGHT="$OPTARG";;
    F) FPS="$OPTARG";;
    c) CODEC="$OPTARG";;
    r) CRF="$OPTARG";;
    p) PRESET="$OPTARG";;
    t) DURATION="$OPTARG";;
    h) usage; exit 0;;
    :) echo "Missing argument for -$OPTARG" >&2; usage; exit 2;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2;;
  esac
done

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "resize-videos" "$1" "$2"
  fi
}

mkdir -p "$OUT_DIR"

# Container/extension selection based on codec
ext=mp4
ff_args=( -an -vf "scale=-2:${HEIGHT}:flags=lanczos,fps=${FPS}" -pix_fmt yuv420p -v error )
case "$CODEC" in
  libx265)
    ff_args+=( -c:v libx265 -crf "$CRF" -preset "$PRESET" -movflags +faststart )
    ext=mp4
    ;;
  libvpx-vp9)
    ff_args+=( -c:v libvpx-vp9 -b:v 0 -crf "$CRF" -row-mt 1 -deadline good -speed 3 )
    ext=webm
    ;;
  libsvtav1)
    ff_args+=( -c:v libsvtav1 -crf "$CRF" -preset "$PRESET" )
    ext=mkv
    ;;
  *) echo "Unsupported codec: $CODEC" >&2; exit 2;;
 esac

# Gather files (common video formats)
shopt -s nullglob
files=( "$SRC_DIR"/*.{mp4,m4v,mp4v,mov,webm,avi,mkv,mpeg,mpg,wmv,flv,ogv,m2ts,ts,3gp,MP4,MOV,WEBM,AVI,MKV} )
shopt -u nullglob

total=${#files[@]}
if [[ "$total" -eq 0 ]]; then
  echo "No source videos found in $SRC_DIR"
  notify "Resize videos: nothing to do" "$SRC_DIR has no matching files"
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
  out="$OUT_DIR/${stem}.${ext}"

  # Skip if up-to-date
  if [[ -f "$out" && "$out" -nt "$f" ]]; then
    progress_bar "$idx" "$total" "$bar_width"
    continue
  fi

  # Build per-file args
  args=( -i "$f" )
  if [[ -n "${DURATION}" ]]; then
    args=( -t "$DURATION" "${args[@]}" )
  fi

  # Run ffmpeg quietly; capture errors via exit code
  if ! ffmpeg -hide_banner "${args[@]}" "${ff_args[@]}" "$out" >/dev/null 2>&1; then
    errors=$((errors + 1))
  fi
  progress_bar "$idx" "$total" "$bar_width"

done
printf "\n"

if [[ "$errors" -gt 0 ]]; then
  echo "Completed with $errors error(s) out of $total files."
  notify "Videos resized with errors" "$errors of $total failed"
  exit 1
else
  echo "Completed successfully: $total video(s) processed."
  notify "Videos resized" "$total processed to $OUT_DIR"
fi

