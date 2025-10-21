{ pkgs }:
pkgs.writeShellScriptBin "wf" ''
    #!/usr/bin/env bash
    # Wfetch Randomizer / Selector
    # Choose between multiple command options randomly, avoiding immediate repeats.
    # Author: Don Williams
    # Revision History
    #==============================================================
    # v0.3      2025-08-21        removed challenge flags where set is unknown 
    # v0.2      2025-08-21        Add --help, selection by number/name, avoid repeats
    # v0.1      5-15-2025         Initial release

    set -euo pipefail

    # Detect invoking shell (parent of this script), map to real path
    parent_pid=$PPID
    parent_name=""
    if [[ -r "/proc/$parent_pid/comm" ]]; then
      parent_name="$(tr -d '\0' < "/proc/$parent_pid/comm")"
    else
      parent_name="$(ps -o comm= -p "$parent_pid" 2>/dev/null || true)"
    fi
    if [[ -z "$parent_name" && -n "${SHELL:-}" ]]; then
      parent_name="$(basename -- "$SHELL")"
    fi

    case "$parent_name" in
      *zsh*) shell="${pkgs.zsh}/bin/zsh" ;;
      *bash*) shell="${pkgs.bash}/bin/bash" ;;
      *fish*) shell="${pkgs.fish}/bin/fish" ;;
      *) shell="$(command -v "$parent_name" 2>/dev/null || true)" ;;
    esac

    if [[ -z "${shell:-}" ]]; then
      shell="${pkgs.zsh}/bin/zsh"
    fi
    # Options definition (index: 1..5 shown to users)
    names=(waifu2 waifu hollow smooth wallpaper)

    # Map name -> command
    run_choice() {
      case "$1" in
        waifu2)    wfetch --waifu2 --image-size 300 ;;
        waifu)     wfetch --waifu --image-size 300 ;;
        hollow)    wfetch --hollow ;;
        smooth)    wfetch --smooth ;;
        wallpaper) wfetch --wallpaper ;;
        *) echo "Unknown choice: $1" >&2; exit 2 ;;
      esac
    }

    build_cmd() {
      case "$1" in
        waifu2)    echo "wfetch --waifu2 --image-size 300" ;;
        waifu)     echo "wfetch --waifu --image-size 300" ;;
        hollow)    echo "wfetch --hollow" ;;
        smooth)    echo "wfetch --smooth" ;;
        wallpaper) echo "wfetch --wallpaper" ;;
        *) echo "Unknown choice: $1" >&2; return 2 ;;
      esac
    }

    print_help() {
      cat <<EOF
  Usage: wf [choice]

  Without an argument, randomly selects one option (avoiding repeating the last selection).

  Choices (by number or name):
    1) waifu2         - Waifu2 image (300px)
    2) waifu          - Waifu image (300px)
    3) hollow         - Hollow icon
    4) smooth         - Smooth icon
    5) wallpaper      - Wallpaper

  Options:
    -h, --help        Show this help message and exit
  EOF
    }

    # Parse args
    if [[ "''${1-}" == "-h" || "''${1-}" == "--help" ]]; then
      print_help
      exit 0
    fi

    normalize_choice() {
      local input="$1"
      case "$input" in
        1|waifu2|WAIFU2) echo "waifu2" ;;
        2|waifu|WAIFU) echo "waifu" ;;
        3|hollow|HOLLOW) echo "hollow" ;;
        4|smooth|SMOOTH) echo "smooth" ;;
        5|wallpaper|WALLPAPER) echo "wallpaper" ;;
        *) return 1 ;;
      esac
    }

    # Resolve choice
    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}"
    mkdir -p "$cache_dir"
    last_file="$cache_dir/wf-last-choice"

    choice=""
    if [[ $# -ge 1 ]]; then
      if ! choice="$(normalize_choice "$1")"; then
        echo "Invalid choice: $1" >&2
        echo "Use --help to see available options." >&2
        exit 2
      fi
    else
      # Random selection avoiding last pick
      last_index=-1
      if [[ -f "$last_file" ]]; then
        # Read last name and map to index
        last_name="$(cat "$last_file" || true)"
        for i in "''${!names[@]}"; do
          if [[ "''${names[$i]}" == "$last_name" ]]; then
            last_index="$i"
            break
          fi
        done
      fi
      # pick index 0..4 excluding last_index if it's valid
      total=''${#names[@]}
      if [[ "$last_index" -ge 0 && "$last_index" -lt "$total" ]]; then
        r=$((RANDOM % (total - 1)))   # 0..3
        [[ $r -ge $last_index ]] && idx=$((r + 1)) || idx=$r
      else
        idx=$((RANDOM % total))
      fi
      choice="''${names[$idx]}"
    fi

    # Persist last selection for next run
    echo "$choice" > "$last_file"

    cmd="$(build_cmd "$choice")"
    exec "$shell" -c "$cmd"
''
