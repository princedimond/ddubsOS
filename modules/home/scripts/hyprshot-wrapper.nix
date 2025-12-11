{pkgs}:
pkgs.writeShellScriptBin "hyprshot-wrapper" ''
  #!/usr/bin/env bash
  set -euo pipefail

  outputDir="$HOME/Pictures/Screenshots"
  mkdir -p "$outputDir"
  ts="$(date +%Y-%m-%d_%H-%M-%S)"
  mode="''${1:-area}" # area|window|screen
  file="$outputDir/hyprshot_${mode}_${ts}.png"

  if command -v hyprshot >/dev/null 2>&1; then
    case "$mode" in
      area)   hyprshot --mode region --freeze --clipboard --silent --output "$file" ;;
      window) hyprshot --mode window --freeze --clipboard --silent --output "$file" ;;
      screen) hyprshot --mode output --freeze --clipboard --silent --output "$file" ;;
      *) echo "Usage: $0 [area|window|screen]"; exit 1 ;;
    esac
  elif command -v grimblast >/dev/null 2>&1; then
    case "$mode" in
      area)   grimblast copysave area "$file" ;;
      window) grimblast copysave active "$file" ;;
      screen) grimblast copysave output "$file" ;;
      *) echo "Usage: $0 [area|window|screen]"; exit 1 ;;
    esac
  else
    echo "Neither hyprshot nor grimblast found" >&2
    exit 1
  fi

  notify-send "Screenshot" "Saved to $file" -i image-x-generic -a "Screenshot" -t 5000
''
