# How to use resize-videos.sh (compact re-encode with progress and notifications)

This guide explains how to use myscripts-repo/resize-videos.sh to re-encode video wallpapers for smaller size with minimal visual loss. The script shows progress, skips up-to-date outputs, and notifies when done.

Requirements
- ffmpeg
- Optional: libnotify (for notify-send)

The script includes a nix shell shebang that provides dependencies automatically when you run it.

Where the script lives
- myscripts-repo/resize-videos.sh

What it does
- Re-encodes videos to your chosen codec, scale, and fps
- Removes audio (wallpapers don’t need sound)
- Picks container based on codec (H.265→mp4, VP9→webm, AV1→mkv)
- Skips files that are already converted and up-to-date
- Shows a per-file progress bar: “Processing N of M [####----] 50%”
- Sends a desktop notification on completion or errors

Defaults
- Source directory: wallpapers
- Destination directory: wallpapers/optimized
- Height: 1080
- FPS: 30
- Codec: libx265 (H.265)
- CRF: 24
- Preset: slow
- Duration cap: none (re-encode full length)

Flags and environment overrides
- Flags:
  - -s DIR: source directory
  - -d DIR: destination directory
  - -H N: output height (keeps aspect)
  - -F N: output fps
  - -c CODEC: libx265 | libvpx-vp9 | libsvtav1
  - -r N: CRF / quality (codec-specific)
  - -p NAME: encoder preset (e.g., slow, medium)
  - -t SEC: duration cap in seconds (optional)
  - -h: help
- Environment:
  - SRC_DIR, OUT_DIR, HEIGHT, FPS, CODEC, CRF, PRESET, DURATION

Examples
- H.265 MP4 at 1080p/30fps:
  ```bash path=null start=null
  myscripts-repo/resize-videos.sh -c libx265 -H 1080 -F 30 -r 24 -p slow
  ```
- VP9 WebM at CRF 32, limit to 20 seconds:
  ```bash path=null start=null
  myscripts-repo/resize-videos.sh -c libvpx-vp9 -r 32 -t 20
  ```
- AV1 MKV at CRF 32, 1440p:
  ```bash path=null start=null
  myscripts-repo/resize-videos.sh -c libsvtav1 -H 1440 -r 32 -p 7
  ```

Tips on size/quality
- H.265 (libx265) is fast and compact; VP9 (libvpx-vp9) is open and high quality; AV1 (libsvtav1) is smallest but slower.
- Raise CRF for smaller files; lower CRF for higher quality.
- A short duration (10–30s) loops seamlessly and keeps sizes small.

Troubleshooting
- "ffmpeg: command not found": the nix shebang should provide it. If you removed the shebang, install ffmpeg or run via nix shell:
  ```bash path=null start=null
  nix shell nixpkgs#ffmpeg nixpkgs#libnotify -c myscripts-repo/resize-videos.sh -h
  ```
- No files found: check the source dir; the script scans a wide range of common video extensions.

