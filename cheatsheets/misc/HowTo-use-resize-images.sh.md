# How to use resize-images.sh (WebP conversion with progress and notifications)

This guide explains how to use myscripts-repo/resize-images.sh to convert and resize still-image wallpapers with minimal perceptual loss. The script shows progress, skips up-to-date outputs, and notifies when done.

Requirements
- libwebp (for cwebp)
- Optional: libnotify (for notify-send)

The script has a nix shell shebang, so dependencies are provided automatically when you run it.

Where the script lives
- myscripts-repo/resize-images.sh

What it does
- Converts images to WebP
- Resizes to a maximum height (keeps aspect ratio)
- Skips files that are already converted and up-to-date
- Shows a per-file progress bar: “Processing N of M [####----] 50%”
- Sends a desktop notification on completion or errors

Defaults
- Source directory: wallpapers
- Destination directory: wallpapers/optimized
- Max height: 1080
- Quality (WebP): 75
- Extensions: jpg,jpeg,png (upper/lower case handled)

Flags and environment overrides
- Flags:
  - -s DIR: source directory
  - -d DIR: destination directory
  - -H N: max height (pixels); 0 to keep original
  - -q N: quality (0–100)
  - -e LIST: comma-separated extensions (e.g., "jpg,jpeg,png")
  - -h: help
- Environment:
  - SRC_DIR, OUT_DIR, MAXH, QUALITY, EXTS

Examples
- Resize to 1440p, quality 80, default dirs:
  ```bash path=null start=null
  myscripts-repo/resize-images.sh -H 1440 -q 80
  ```
- Convert a different source into a custom output dir:
  ```bash path=null start=null
  myscripts-repo/resize-images.sh -s Pictures/Wallpapers -d Pictures/Wallpapers/optimized
  ```
- Use environment variables instead of flags:
  ```bash path=null start=null
  SRC_DIR=wallpapers OUT_DIR=wallpapers/optimized MAXH=1440 QUALITY=80 \
    myscripts-repo/resize-images.sh
  ```

Notes on quality
- WebP quality ~80 is usually visually identical; raise or lower to taste.
- For 4K displays, 1440 max height is a great balance. 1080 is fine for most use.

Troubleshooting
- "cwebp: command not found": the nix shebang should provide it. If you removed the shebang, install libwebp or run via nix shell:
  ```bash path=null start=null
  nix shell nixpkgs#libwebp nixpkgs#libnotify -c myscripts-repo/resize-images.sh
  ```
- No files found: check the source dir and extensions list.

