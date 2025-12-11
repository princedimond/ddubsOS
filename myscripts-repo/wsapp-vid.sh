#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input-video> <output-video>"
  exit 1
fi

INPUT="$1"
OUTPUT="$2"

ffmpeg -i "$INPUT" \
  -c:v libx264 -preset medium -crf 23 -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  "$OUTPUT"

