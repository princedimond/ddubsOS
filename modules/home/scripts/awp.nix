{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "awp";
  # Provide jq and procps (pgrep) at runtime; mpvpaper is intentionally not
  # included so the script can check for it and warn if missing.
  runtimeInputs = with pkgs; [
    jq
    procps
    gnused
    gawk
    coreutils
    ffmpeg
    libnotify
  ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    wallpapers_dir="''${WALLPAPERS_DIR:-$HOME/Pictures/Wallpapers}"
    choice=""
    file=""
    mon=""
    do_kill=false
    do_fill=false
    do_stretch=false

    usage() { cat <<'EOF'
    Usage: awp [1|2|3...] [-f|--file FILE] [-m|--mon MONITOR|all] [--fill|--stretch] [-k|--kill]
    Examples:
      awp 1
      awp -f Animated-Space-Room-2.mp4
      awp -f "$HOME/Videos/custom.mp4" -m all
      awp 2 -m HDMI-A-1
      awp --kill              # kill all mpvpaper instances
      awp -k -m HDMI-A-1      # kill mpvpaper on a single monitor
      awp -f foo.avif --fill  # crop-fill to screen (preserve aspect)
      awp -f bar.avif --stretch  # stretch to fill screen (ignore aspect)
    Environment:
      WALLPAPERS_DIR   Directory to search for wallpapers (default: ~/Pictures/Wallpapers)
    EOF
    }

    # parse args
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help) usage; exit 0;;
        -f|--file)
          [[ $# -ge 2 ]] || { echo "Missing arg for $1" >&2; exit 2; }
          file="$2"; shift 2;;
        -m|--mon)
          [[ $# -ge 2 ]] || { echo "Missing arg for $1" >&2; exit 2; }
          mon="$2"; shift 2;;
        -k|--kill)
          do_kill=true; shift;;
        --fill)
          do_fill=true; shift;;
        --stretch)
          do_stretch=true; shift;;
        ""|*[!0-9]*)
          echo "Unknown argument: $1" >&2; usage; exit 2;;
        *)
          choice="$1"; shift;;
      esac
    done

    # handle kill mode early
    if [[ "''${do_kill}" == "true" ]]; then
      # default to all if -m not provided
      if [[ -z "''${mon:-}" ]]; then
        mon="all"
      fi
      if [[ "''${mon}" == "all" ]]; then
        # find mpvpaper PIDs robustly (covers both plain and --fork forms)
        pids="$(pgrep -x mpvpaper || pgrep -f '(^|/)mpvpaper( |$)' || true)"
        if [[ -n "''${pids}" ]]; then
          echo "Killing mpvpaper PIDs: ''${pids}" >&2
          # shellcheck disable=SC2086
          kill ''${pids} >/dev/null 2>&1 || true
        else
          echo "No mpvpaper instances running." >&2
        fi
        exit 0
      else
        # kill only instances with the monitor token present as a separate arg
        pids="$(pgrep -f -a mpvpaper | awk -v m="''${mon}" '{ pid=$1; $1=""; cmd=$0; if (cmd ~ ("(^|[[:space:]])" m "([[:space:]]|$)")) print pid }')"
        if [[ -n "''${pids}" ]]; then
          echo "Killing mpvpaper for monitor ''${mon}: ''${pids}" >&2
          # shellcheck disable=SC2086
          kill ''${pids} >/dev/null 2>&1 || true
        else
          echo "No mpvpaper processes found for monitor ''${mon}." >&2
        fi
        exit 0
      fi
    fi

    # map choice to file if no -f
    if [[ -z "''${file}" && -n "''${choice}" ]]; then
      case "''${choice}" in
        1) file="''${wallpapers_dir}/Animated-Space-Room-1.mp4";;
        2) file="''${wallpapers_dir}/Animated-Space-Room-2.mp4";;
        *) echo "Unsupported choice: ''${choice}. Use -f to specify a file." >&2; exit 2;;
      esac
    fi

    # if -f provided and not absolute, resolve within wallpapers_dir when not containing '/'
    if [[ -n "''${file}" ]]; then
      if [[ "''${file}" != /* && "''${file}" != *"/"* ]]; then
        file="''${wallpapers_dir}/''${file}"
      fi
      # expand leading ~
      if [[ "''${file}" == ~* ]]; then
        file="''${file/#\~/$HOME}"
      fi
    fi

    # prune cached conversions whose source AVIF no longer exists
    (
      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/awp/converted"
      if [[ -d "''${cache_dir}" ]]; then
        shopt -s nullglob
        for c in "''${cache_dir}"/*.webm; do
          base="$(basename -- "''${c}")"
          name_no_ext="''${base%.webm}"
          stem="''${name_no_ext%.*}"
          if [[ ! -f "''${wallpapers_dir}/''${stem}.avif" && ! -f "''${wallpapers_dir}/''${stem}.AVIF" ]]; then
            rm -f -- "''${c}" || true
          fi
        done
        shopt -u nullglob
      fi
    )

    if [[ -z "''${file}" ]]; then
      echo "No wallpaper selected. Provide a numeric choice or -f FILE." >&2
      usage
      exit 2
    fi

    if [[ ! -f "''${file}" ]]; then
      echo "File not found: ''${file}" >&2
      exit 1
    fi

    # If the input is an AVIF (animated), transcode once to a longer WebM in cache
    case "''${file}" in
      *.avif|*.AVIF)
        cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/awp/converted"
        mkdir -p "''${cache_dir}"
        stem="$(basename -- "''${file}")"; stem="''${stem%.*}"
        sha="$(sha256sum "''${file}" | awk '{print $1}' | cut -c1-16)"
        cached="''${cache_dir}/''${stem}.''${sha}.webm"
        if [[ ! -f "''${cached}" ]]; then
          echo "Transcoding AVIF to WebM cache for smooth looping..." >&2
          # Notify user to explain the pause
          if command -v notify-send >/dev/null 2>&1; then
            notify-send -a "awp" "Converting AVIF for smooth looping" "Preparing ''${stem}.avif — this one-time step may take a moment"
          fi
          # clean older cached variants for the same stem
          rm -f "''${cache_dir}/''${stem}."*.webm 2>/dev/null || true
          # Create a ~60s VP9 WebM by looping the short source; faster settings to keep latency low
          if ! ffmpeg -y -v error -hide_banner -stats \
              -stream_loop -1 -t 60 -i "''${file}" -an \
              -c:v libvpx-vp9 -crf 32 -b:v 0 -row-mt 1 -tile-columns 2 -deadline good -speed 4 \
              -pix_fmt yuv420p "''${cached}"; then
            echo "Warning: AVIF transcode failed; using original file." >&2
          fi
        fi
        if [[ -f "''${cached}" ]]; then
          file="''${cached}"
        fi
        ;;
    esac

    if ! command -v mpvpaper >/dev/null 2>&1; then
      echo "Error: mpvpaper is not installed or not in PATH." >&2
      echo "Please install mpvpaper and try again." >&2
      exit 127
    fi

    # non-fatal swww notice
    if command -v pgrep >/dev/null 2>&1 && pgrep -x swww-daemon >/dev/null 2>&1; then
      echo "Note: swww-daemon is running; mpvpaper may warn. Continuing..." >&2
    fi

    get_monitors() {
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl -j monitors 2>/dev/null | jq -r '.[].name' | sed '/^$/d' && return 0
      fi
      if command -v swaymsg >/dev/null 2>&1; then
        swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.active==true).name' | sed '/^$/d' && return 0
      fi
      if command -v wlr-randr >/dev/null 2>&1; then
        wlr-randr 2>/dev/null | awk '/ connected/ {print $1}'
        return 0
      fi
      return 1
    }

    get_focused_monitor() {
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused==true).name' | head -n1
        return 0
      fi
      if command -v swaymsg >/dev/null 2>&1; then
        swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.focused==true).name' | head -n1
        return 0
      fi
      echo ""
    }

    if [[ -z "''${mon:-}" ]]; then
      # try focused, fallback to first
      mon="$(get_focused_monitor || true)"
      if [[ -z "''${mon}" ]]; then
        mon="$(get_monitors | head -n1 || true)"
      fi
    fi

    if [[ -z "''${mon}" ]]; then
      echo "Could not detect a monitor. Use -m MONITOR or -m all." >&2
      exit 1
    fi

    # Replace any existing mpvpaper instance(s) for the target monitor(s)
    if [[ "''${mon}" == "all" ]]; then
      pids="$(pgrep -x mpvpaper || pgrep -f '(^|/)mpvpaper( |$)' || true)"
      if [[ -n "''${pids}" ]]; then
        # shellcheck disable=SC2086
        kill ''${pids} >/dev/null 2>&1 || true
      fi
    else
      pids="$(pgrep -f -a mpvpaper | awk -v m="''${mon}" '{ pid=$1; $1=""; cmd=$0; if (cmd ~ ("(^|[[:space:]])" m "([[:space:]]|$)")) print pid }')"
      if [[ -n "''${pids}" ]]; then
        # shellcheck disable=SC2086
        kill ''${pids} >/dev/null 2>&1 || true
      fi
    fi

    # build mpv options — use proper mpv syntax (space-separated, prefixed with --)
    # loop video indefinitely and disable audio
    mpv_opts=(--loop-file=inf --no-audio)
    if [[ "''${do_fill}" == "true" ]]; then
      mpv_opts+=(--panscan=1.0)
    elif [[ "''${do_stretch}" == "true" ]]; then
      mpv_opts+=(--keepaspect=no)
    fi
    mpv_opts_str="''${mpv_opts[*]}"

    run_on_monitor() {
      local m="$1"
      echo "Setting ''${file} on monitor ''${m}..."
      # follow original ordering known to work with mpvpaper
      mpvpaper "''${m}" "''${file}" -f -s -o "''${mpv_opts_str}"
    }

    if [[ "''${mon}" == "all" ]]; then
      mons="$(get_monitors || true)"
      if [[ -z "''${mons}" ]]; then
        echo "Could not enumerate monitors for -m all." >&2
        exit 1
      fi
      while IFS= read -r m; do
        # run each in background
        run_on_monitor "''${m}" &
      done <<< "''${mons}"
      wait
    else
      run_on_monitor "''${mon}"
    fi
  '';
}
