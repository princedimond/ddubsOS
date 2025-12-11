{pkgs}:
pkgs.writeShellScriptBin "wsapp-vid" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    usage() {
      cat <<EOF
  Usage: wsapp-vid INPUT [OUTPUT]

  Converts a video to a WhatsApp-friendly MP4 (H.264 + AAC, <= 1280px wide, 30fps).
  If OUTPUT is omitted, writes alongside INPUT as <name>-wsapp.mp4.
  EOF
    }

    if [ "''${1:-}" = "-h" ] || [ "''${1:-}" = "--help" ]; then
      usage
      exit 0
    fi

    if [ "$#" -lt 1 ]; then
      usage
      exit 1
    fi

    in="$1"
    if [ ! -f "$in" ]; then
      echo "Input file not found: $in" >&2
      exit 1
    fi

    if [ "$#" -ge 2 ]; then
      out="$2"
    else
      base=$(${pkgs.coreutils}/bin/basename "$in")
      out="''${base%.*}-wsapp.mp4"
    fi

    echo "Converting '$in' -> '$out' for WhatsApp..." >&2

    ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$in" \
      -vf "scale='min(1280,iw)':-2,fps=30" \
      -c:v libx264 -preset veryfast -profile:v high -level:v 4.1 -pix_fmt yuv420p \
      -c:a aac -b:a 128k \
      -movflags +faststart \
      "$out"
''
