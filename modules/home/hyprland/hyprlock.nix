{
  host,
  config,
  pkgs,
  username,
  ...
}: let
  # Bring in the Stylix wallpaper image for the default background
  inherit (import ../../../hosts/${host}/variables.nix) stylixImage;

  # Stylix base16 colors exposed via lib.stylix.colors
  colors = config.lib.stylix.colors;

  # Helper scripts packaged via Nix
  pythonWithRequests = pkgs.python3.withPackages (ps: [ps.requests]);

  uptimeScript = pkgs.writeShellScriptBin "hyprlock-uptime" ''
    #!/usr/bin/env bash
    # Fallback-friendly uptime (like your UptimeNixOS.sh)
    if [[ -r /proc/uptime ]]; then
      s=$(< /proc/uptime)
      s=''${s/.*}
    else
      if command -v uptime >/dev/null 2>&1; then
        uptime -p
        exit 0
      fi
      echo "Error: Uptime could not be determined." >&2
      exit 1
    fi

    d="$((s / 60 / 60 / 24)) days"
    h="$((s / 60 / 60 % 24)) hours"
    m="$((s / 60 % 60)) minutes"

    (( ''${d/ *} == 1 )) && d=''${d/s}
    (( ''${h/ *} == 1 )) && h=''${h/s}
    (( ''${m/ *} == 1 )) && m=''${m/s}

    (( ''${d/ *} == 0 )) && unset d
    (( ''${h/ *} == 0 )) && unset h
    (( ''${m/ *} == 0 )) && unset m

    uptime=''${d:+$d, }''${h:+$h, }$m
    uptime=''${uptime%', '}
    uptime=''${uptime:-$s seconds}
    printf 'up %s\n' "$uptime"
  '';

  batteryScript = pkgs.writeShellScriptBin "hyprlock-battery" ''
    #!/usr/bin/env bash
    for i in {0..3}; do
      if [ -f /sys/class/power_supply/BAT"$i"/capacity ]; then
        status=$(cat /sys/class/power_supply/BAT"$i"/status)
        capacity=$(cat /sys/class/power_supply/BAT"$i"/capacity)
        echo "Battery: ''${capacity}% (''${status})"
      fi
    done
  '';

  # Create/refresh a symlink that points to the current wallpaper if available,
  # otherwise point to the Stylix image. Hyprlock can then read a stable path.
  linkScript = pkgs.writeShellScriptBin "hyprlock-update-wallpaper-link" ''
    #!/usr/bin/env bash
    set -euo pipefail

    STATE_JSON="${config.xdg.stateHome or "$HOME/.local/state"}/qs-wallpapers/current.json"
    STATE_TXT="${config.xdg.stateHome or "$HOME/.local/state"}/qs-wallpapers/current_wallpaper"

    CACHE_DIR="${config.xdg.cacheHome or "$HOME/.cache"}/hyprlock"
    LINK_PATH="$CACHE_DIR/wallpaper_current"

    mkdir -p "$CACHE_DIR"

    # Try to resolve the current wallpaper path from qs-wallpapers state
    WP_PATH=""
    if [ -f "$STATE_JSON" ] && command -v jq >/dev/null 2>&1; then
      WP_PATH=$(jq -r '.path // ""' "$STATE_JSON" 2>/dev/null || true)
    fi
    if [ -z "''${WP_PATH:-}" ] && [ -f "$STATE_TXT" ]; then
      WP_PATH=$(head -n1 "$STATE_TXT" 2>/dev/null || true)
    fi

    # Validate and pick fallback
    if [ -n "''${WP_PATH:-}" ] && [ -f "$WP_PATH" ]; then
      :
    else
      WP_PATH='${stylixImage}'
    fi

    ln -sfn "$WP_PATH" "$LINK_PATH"
  '';

  # Weather: install script from repo into the store and a runner to refresh cache
  weatherPy = pkgs.writeText "Weather.py" (builtins.readFile ../scripts/weather/Weather.py);
  weatherUpdate = pkgs.writeShellScriptBin "hyprlock-weather-update" ''
    #!/usr/bin/env bash
    # Refresh weather cache; quiet errors
    ${pythonWithRequests}/bin/python ${weatherPy} >/dev/null 2>&1 || true
  '';

  # Absolute paths to scripts for hyprlock labels
  uptimeBin = "${uptimeScript}/bin/hyprlock-uptime";
  batteryBin = "${batteryScript}/bin/hyprlock-battery";
  linkBin = "${linkScript}/bin/hyprlock-update-wallpaper-link";
  weatherUpdateBin = "${weatherUpdate}/bin/hyprlock-weather-update";

  # Common fonts
  monoFont = config.stylix.fonts.monospace.name or "JetBrains Mono";
  uiFont = config.stylix.fonts.sansSerif.name or "Montserrat";
in {
  # Ensure helper scripts are available
  home.packages = [uptimeScript batteryScript linkScript weatherUpdate pythonWithRequests];

  # Run the wallpaper link update at login so hyprlock can pick up the current wallpaper
  systemd.user.services.hyprlock-wallpaper-link = {
    Unit = {
      Description = "Update hyprlock wallpaper link from qs-wallpapers state";
    };
    Service = {
      Type = "oneshot";
      ExecStart = linkBin;
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

  # Periodically refresh link so updates from external tools (e.g., waypaper) are picked up
  systemd.user.timers.hyprlock-wallpaper-link = {
    Unit.Description = "Timer: update hyprlock wallpaper link";
    Timer = {
      OnBootSec = "10s";
      OnUnitActiveSec = "1m";
      Unit = "hyprlock-wallpaper-link.service";
    };
    Install.WantedBy = ["timers.target" "hyprland-session.target"];
  };

  # Weather cache refresher (every 10 minutes, start soon after login)
  systemd.user.services.hyprlock-weather-update = {
    Unit = {
      Description = "Refresh weather cache for hyprlock";
    };
    Service = {
      Type = "oneshot";
      ExecStart = weatherUpdateBin;
      Environment = [
        # Customize defaults here if desired
        # "WEATHER_UNITS=metric"
        # "WEATHER_TOOLTIP_MARKUP=0"
      ];
    };
  };

  systemd.user.timers.hyprlock-weather-update = {
    Unit.Description = "Timer: refresh weather cache for hyprlock";
    Timer = {
      OnBootSec = "15s";
      OnUnitActiveSec = "10m";
      Unit = "hyprlock-weather-update.service";
    };
    Install.WantedBy = ["timers.target" "hyprland-session.target"];
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 1; # close to model; small grace period
        fractional_scaling = 2;
        immediate_render = true;
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
      };

      # Background: prefer the linked current wallpaper (refreshed at login),
      # falls back to Stylix image if no selection exists yet.
      background = [
        {
          monitor = "";
          path = "${config.xdg.cacheHome or "$HOME/.cache"}/hyprlock/wallpaper_current";
          color = "rgb(0,0,0)"; # initial until path is available
          blur_size = 3;
          blur_passes = 2;
          noise = 0.0117;
          contrast = 1.3;
          brightness = 0.8;
          vibrancy = 0.21;
          vibrancy_darkness = 0.0;
        }
      ];

      # Date (top center)
      label = [
        {
          monitor = "";
          text = "cmd[update:1800000] echo \"<b> \"$(date +'%A, %-d %B')\" </b>\"";
          color = "rgb(${colors.base0D})";
          font_size = 16;
          font_family = "${uiFont} Bold";
          position = "0, 120";
          halign = "center";
          valign = "top";
        }

        # Horizontal time (single centered label to avoid overlap)
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +'%I:%M %p')\"";
          color = "rgb(${colors.base05})";
          font_size = 120;
          font_family = "${monoFont} Nerd Font ExtraBold";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }

        # User (bottom center)
        {
          monitor = "";
          text = "  $USER";
          color = "rgb(${colors.base0D})";
          font_size = 24;
          font_family = "${uiFont} Bold";
          position = "0, 100";
          halign = "center";
          valign = "bottom";
        }

        # Keyboard layout (bottom center)
        {
          monitor = "";
          text = "$LAYOUT";
          color = "rgb(${colors.base05})";
          font_size = 10;
          font_family = "${uiFont} Bold";
          position = "0, 70";
          halign = "center";
          valign = "bottom";
        }

        # Uptime (bottom right)
        {
          monitor = "";
          text = "cmd[update:60000] ${uptimeBin}";
          color = "rgb(${colors.base05})";
          font_size = 16;
          font_family = "${uiFont} Bold";
          position = "0, 0";
          halign = "right";
          valign = "bottom";
        }

        # Battery (bottom right)
        {
          monitor = "";
          text = "cmd[update:10000] ${batteryBin}";
          color = "rgb(${colors.base05})";
          font_size = 16;
          font_family = "${uiFont} Bold";
          position = "0, 30";
          halign = "right";
          valign = "bottom";
        }

        # ddubsOS version from env (modules/core/system.nix should export DDUBSOS_VERSION)
        {
          monitor = "";
          text = "cmd[update:18000000] echo \"ddubsOS version: $DDUBSOS_VERSION\"";
          color = "rgb(${colors.base05})";
          font_size = 16;
          font_family = "${uiFont} Bold";
          position = "-15, 60";
          halign = "right";
          valign = "bottom";
        }

        # Powered by NixOS (snowflake icon)
        {
          monitor = "";
          text = "❄️ Powered by NixOS";
          color = "rgb(${colors.base05})";
          font_size = 16;
          font_family = "${uiFont} Bold";
          position = "-15, 90";
          halign = "right";
          valign = "bottom";
        }

        # Weather (bottom left): reads simple cache file written by Weather.py
        {
          monitor = "";
          text = "cmd[update:3600000] [ -f '$HOME/.cache/.weather_cache' ] && cat '$HOME/.cache/.weather_cache'";
          color = "rgb(${colors.base05})";
          font_size = 16;
          font_family = "${uiFont} Bold";
          position = "50, 0";
          halign = "left";
          valign = "bottom";
        }
      ];

      # Input field (bottom center)
      input-field = [
        {
          monitor = "";
          size = "200, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgb(${colors.base0E})";
          inner_color = "rgba(255, 255, 255, 0.10)";
          capslock_color = "rgb(255,255,255)";
          font_color = "rgb(${colors.base05})";
          fade_on_empty = false;
          font_family = "${uiFont} Bold";
          placeholder_text = "🔒 Type Password";
          hide_input = false;
          position = "0, -60";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
