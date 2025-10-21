{ pkgs,
  username,
  profile,
  config,
  ...
}:
let
  thumbsBuilder = import ./wallpaper-thumbs-build.nix { inherit pkgs; };
  rofiWallpapers = import ./rofi-wallpapers.nix { inherit pkgs; };
  qsWallpapers = import ./qs-wallpapers.nix { inherit pkgs; };
  qsWallpapersApply = import ./qs-wallpapers-apply.nix { inherit pkgs; };
  qsWallpapersRestore = import ./qs-wallpapers-restore.nix { inherit pkgs; };
  keybindsParser = import ./keybinds-parser.nix { inherit pkgs; };
  qsKeybinds = import ./qs-keybinds.nix { inherit pkgs; };
  cheatsheetsParser = import ./cheatsheets-parser.nix { inherit pkgs; };
  qsCheatsheets = import ./qs-cheatsheets.nix { inherit pkgs; };
  docsParser = import ./docs-parser.nix { inherit pkgs; };
  qsDocs = import ./qs-docs.nix { inherit pkgs; };
in
{
  home.packages = [
    (import ./emopicker9000.nix { inherit pkgs; })
    (import ./awp.nix { inherit pkgs; })
    (import ./awp-menu.nix { inherit pkgs; })
    (import ./edp.off.nix { inherit pkgs; })
    (import ./ff.nix { inherit pkgs; })
    (import ./ff1.nix { inherit pkgs; })
    (import ./ff2.nix { inherit pkgs; })
    (import ./glances-server.nix { inherit pkgs; })
    (import ./git-mirror.nix { inherit pkgs; })
    (import ./hp.reset.nix { inherit pkgs; })
    (import ./hyprland-dock.nix { inherit pkgs; })
    (import ./hm-find.nix { inherit pkgs; })
    (import ./keybinds.nix { inherit pkgs; })
    (import ./screenshootin.nix { inherit pkgs; })
    (import ./screenshootin-satty.nix { inherit pkgs; })
    (import ./start-polkit-agent.nix { inherit pkgs; })
    (import ./squirtle.nix { inherit pkgs; })
    (import ./swap_layout.nix { inherit pkgs; })
    (import ./task-waybar.nix { inherit pkgs; })
    (import ./niri-start.nix { inherit pkgs; })
    (import ./note.nix { inherit pkgs; })
    (import ./note-from-clipboard.nix { inherit pkgs; })
    (import ./nvidia-offload.nix { inherit pkgs; })
    (import ./rofi.menu.nix { inherit pkgs; })
    (import ./rofi-legacy.menu.nix { inherit pkgs; })
    (import ./rofi-launcher.nix { inherit pkgs; })
    rofiWallpapers
    (import ./rofi-wallpapers-apply.nix { inherit pkgs; })
    qsWallpapers
    qsWallpapersApply
    qsWallpapersRestore
    keybindsParser
    qsKeybinds
    cheatsheetsParser
    qsCheatsheets
    docsParser
    qsDocs
    (import ./qs-vid-wallpapers.nix { inherit pkgs; })
    (import ./qs-vid-wallpapers-apply.nix { inherit pkgs; })
    (import ./qs-wlogout.nix { inherit pkgs; })
    thumbsBuilder
    (import ./total-uptime.nix { inherit pkgs; })
    (import ./total_time.nix { inherit pkgs; })
    (import ./wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ./web-search.nix { inherit pkgs; })
    (import ./wf.nix { inherit pkgs; })

    (import ./zcli.nix {
      inherit pkgs profile;
      backupFiles = [
        ".config/mimeapps.list.backup"
        # Add other backup files here, e.g.:
        # ".config/some-other-app.conf.bak"
      ];
    })
    (import ./warp-check.nix { inherit pkgs; })
    (import ./smart-gaps.nix { inherit pkgs; })
  ];

  # Default wallpaper backend for qs-wallpapers-apply
  home.sessionVariables = {
    WALLPAPER_BACKEND = "mpvpaper";
  };

  # Install a hyprshot wrapper in ~/.local/bin to set a default output dir
  home.file = {
    ".local/bin/hyprshot" = {
      text = ''
        #!/usr/bin/env bash
        DEFAULT_DIR="$HOME/Pictures/Screenshots"
        mkdir -p "$DEFAULT_DIR"

        has_output_flag=false
        for arg in "$@"; do
          case "$arg" in
            -o|--output|--output-dir|--output-folder)
              has_output_flag=true
              break
              ;;
          esac
        done

        if $has_output_flag; then
          exec "${pkgs.hyprshot}/bin/hyprshot" "$@"
        else
          exec "${pkgs.hyprshot}/bin/hyprshot" -o "$DEFAULT_DIR" "$@"
        fi
      '';
      executable = true;
    };
  };

  # Pre-build wallpaper thumbnails at activation to speed up rofi display
  home.activation.wallpaperThumbCache = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    WALL_DIR="$HOME/Pictures/Wallpapers"
    CACHE_DIR="$HOME/.cache/wallthumbs"
    SIZE="200"

    mkdir -p "$CACHE_DIR"
    if [ -d "$WALL_DIR" ]; then
      # Prebuild thumbnails
      ${thumbsBuilder}/bin/wallpaper-thumbs-build -q -d "$WALL_DIR" -t "$CACHE_DIR" -s "$SIZE"

      # Build a precomputed JSON manifest for fast runtime startup
      MANIFEST="$CACHE_DIR/walls.json"
      tmpman=$(mktemp)
      printf "[" > "$tmpman"
      first=1
      # shellcheck disable=SC2044
      # Build sorted list of image paths (case-insensitive), NUL-delimited for safety
      while IFS= read -r -d $'\0' img; do
        # Compute path-hash for thumb filename (same scheme as runtime fallback)
        hash=$(printf "%s" "$img" | sha256sum | cut -d' ' -f1)
        thumb="$CACHE_DIR/$hash.png"
        bname=$(basename "$img")
        name=$(printf "%s" "$bname" | sed 's/\.[^.]*$//')
        if [ $first -eq 0 ]; then printf "," >> "$tmpman"; fi
        first=0
        # Escape JSON strings safely
        jpath=$(printf "%s" "$img" | sed "s/\\\\/\\\\\\\\/g;s/\"/\\\"/g")
        jname=$(printf "%s" "$name" | sed "s/\\\\/\\\\\\\\/g;s/\"/\\\"/g")
        jthumb=$(printf "%s" "$thumb" | sed "s/\\\\/\\\\\\\\/g;s/\"/\\\"/g")
        printf "{\"path\":\"%s\",\"name\":\"%s\",\"thumb\":\"%s\"}" "$jpath" "$jname" "$jthumb" >> "$tmpman"
      done < <(find -L "$WALL_DIR" \( -type f -o -xtype f \) \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' -o -iname '*.bmp' -o -iname '*.tiff' \) -print0 2>/dev/null \
        | sort -z -f)
      printf "]" >> "$tmpman"
      mv "$tmpman" "$MANIFEST"
    fi
  '';
}
