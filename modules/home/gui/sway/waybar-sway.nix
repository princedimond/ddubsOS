{
  pkgs,
  lib,
  host,
  config,
  ...
}: let
  vars = import ../../../../hosts/${host}/variables.nix;
  clock24h = vars.clock24h or false;
  weatherLocation = vars.weatherLocation or "";
  # Icons for custom buttons
  powerIcon = "⏻";
  startIcon = "";
  fontFamily = "Iosevka Nerd Font";
  altIconFont = "feather"; # if present; falls back if missing

  cfgObject = [
    {
      layer = "top";
      position = "top";
      height = 36;
      spacing = 8;

      # Layout including requested custom modules
      "modules-left" = [
        "custom/startmenu"
        "sway/workspaces"
        "sway/window"
      ];
      "modules-center" = ["clock"];
      "modules-right" = [
        "pulseaudio"
        "battery"
        "tray"
        "idle_inhibitor"
        "custom/weather"
        "custom/powermenu"
      ];

      # Sway workspaces (no persistent set)
      "sway/workspaces" = {
        format = "{name}";
        "disable-scroll" = false;
        "on-scroll-up" = "swaymsg workspace next";
        "on-scroll-down" = "swaymsg workspace prev";
      };

      "sway/window" = {
        "max-length" = 60;
        rewrite = {"" = " 🙈 No Windows? ";};
      };

      # Clock
      clock = {
        format =
          if clock24h == true
          then '' {:L%H:%M}''
          else '' {:L%I:%M %p}'';
        tooltip = true;
        "tooltip-format" = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
      };

      # Audio
      pulseaudio = {
        format = "{icon} {volume}% {format_source}";
        "format-muted" = " {format_source}";
        "format-source" = " {volume}%";
        "format-source-muted" = "";
        "format-icons" = {
          default = ["" "" ""];
          headphone = "";
        };
        "on-click" = "pavucontrol";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        "format-charging" = "󰂄 {capacity}%";
        "format-plugged" = "󱘖 {capacity}%";
        "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        tooltip = false;
      };

      tray = {
        spacing = 12;
        "icon-size" = 24;
      };

      idle_inhibitor = {
        tooltip = true;
        "tooltip-format-activated" = "Idle_inhibitor active";
        "tooltip-format-deactivated" = "Idle_inhibitor not active";
        format = "{icon}";
        "format-icons" = {
          activated = " ";
          deactivated = " ";
        };
      };

      # Requested custom modules
      "custom/startmenu" = {
        tooltip = true;
        "tooltip-format" = "App menu";
        format = startIcon;
        "on-click" = "rofi -show drun";
        "on-click-right" = "nwg-drawer -mr 225 -ml 225 -mt 200 -mb 200 -is 48 --spacing 15";
      };

      "custom/powermenu" = {
        tooltip = true;
        "tooltip-format" = "Power: rofi menu";
        format = powerIcon;
        "on-click" = "~/.config/waybar/scripts/sway-power-menu.sh";
        "on-click-right" = "~/.config/waybar/scripts/sway-power-menu.sh";
      };

      # Weather module using wttr.in via local script; set weatherLocation in host variables to pin location
      "custom/weather" = {
        "return-type" = "json";
        interval = 900; # seconds
        exec =
          if weatherLocation == ""
          then ''sh -lc 'env WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 timeout 3s ~/.config/waybar/scripts/Weather.py || echo "{\"text\":\"--\"}"' ''
          else ''sh -lc 'env WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 timeout 3s ~/.config/waybar/scripts/Weather.py ${weatherLocation} || echo "{\"text\":\"--\"}"' '';
        tooltip = true;
        format = "{text}";
      };
    }
  ];

  configJson = builtins.toJSON cfgObject;

  styleCss = lib.concatStrings [
    ''
      * {
        font-family: "${fontFamily}", "${altIconFont}", monospace;
        font-size: 20px;
        font-weight: bold;
      }
      window#waybar {
        background-color: rgba(26,27,38,0.7);
        color: #a9b1d6;
        padding-left: 28px;
        padding-right: 10px;
        padding-bottom: 10px; /* extra visual gap below bar content */
        margin-left: 16px;
        margin-right: 6px;
      }
      #tray {
        padding-right: 8px;
        margin-right: 6px;
      }
      #pulseaudio, #battery, #tray, #idle_inhibitor, #custom-weather, #custom-powermenu {
        margin-left: 10px;
      }
      #custom-powermenu {
        padding-right: 4px;
        margin-right: 4px;
      }
      #custom-startmenu { margin-left: 10px; margin-right: 18px; }
      #workspaces { margin-right: 14px; margin-bottom: 4px; }
      #window { margin-left: 14px; }
      #workspaces button { padding: 0 6px; }
      #clock { border-bottom: 3px solid #7aa2f7; }
      #pulseaudio { border-bottom: 3px solid #bb9af7; }
      #idle_inhibitor.activated { color: #9ece6a; }
      #idle_inhibitor.deactivated { color: #f7768e; }

      /* Workspace styles: no reverse colors; focused = purple underline; occupied green; free red */
      #workspaces button {
        background: transparent;
        color: #f7768e; /* free */
      }
      #workspaces button:not(.empty) {
        color: #9ece6a; /* occupied */
      }
      #workspaces button.focused,
      #workspaces button.active,
      #workspaces button.visible {
        border-bottom: 3px solid #ad8ee6; /* purple underline */
        padding-bottom: 2px;
      }
    ''
  ];
in
  with lib; {
    xdg.configFile."sway/waybar/config.jsonc".text = configJson;
    xdg.configFile."sway/waybar/style.css".text = styleCss;
  }
