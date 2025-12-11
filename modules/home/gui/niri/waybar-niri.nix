{
  pkgs,
  lib,
  host,
  config,
  ...
}: let
  # Reuse Waybar helper scripts from the Hyprland setup
  scriptsDir = ../../waybar/scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);

  # Use Python with requests for the weather script
  pythonWithRequests = pkgs.python3.withPackages (ps: [ps.requests]);

  # Base bar configuration adapted for Niri
  barCfg = {
    layer = "top";
    position = "top";
    height = 30;
    spacing = 4;

    modules-left = [
      "custom/startmenu"
      "custom/sep_gap_left"
      "custom/waypaper"
      "custom/sep"
      "niri/workspaces"
      "custom/sep"
      "niri/window"
      "custom/sep"
    ];
    modules-center = [
      "idle_inhibitor"
      "custom/weather"
      "custom/notification"
    ];
    modules-right = [
      "custom/sep"
      "tray"
      "custom/sep"
      "pulseaudio"
      "cpu"
      "clock"
      "custom/sep"
      "custom/power"
    ];

    # Niri modules
    "niri/workspaces" = {
      disable-scroll = true;
      all-outputs = true;
      warp-on-scroll = false;
      # Drop the colon; show name when present
      format = "{index} {name}";
    };
    "niri/window" = {
      max-length = 40;
      seperate-outputs = false;
    };

    tray = {spacing = 10;};
    clock = {format-alt = "{:%Y-%m-%d}";};
    cpu = {
      format = "CPU: {usage}%";
      tooltip = false;
    };
    memory = {format = "Mem: {used}GiB";};
    disk = {
      interval = 60;
      path = "/";
      format = "Disk: {free}";
    };

    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15;
      };
      format = "Bat: {capacity}% {icon} {time}";
      format-plugged = "{capacity}% ";
      format-alt = "Bat {capacity}%";
      format-time = "{H}:{M}";
      format-icons = ["" "" "" "" ""];
    };

    network = {
      format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
      format-ethernet = "{ifname} {ipaddr}";
      format-wifi = "{essid} {signalStrength}% {ipaddr}";
      format-disconnected = "󰤮";
      tooltip = true;
      tooltip-format = "{ifname}\nIPv4: {ipaddr}/{cidr}\nGateway: {gwaddr}\nSSID: {essid}\nSignal: {signalStrength}%";
      on-click = "nmtui";
    };

    "custom/sep" = {
      format = "|";
      interval = 0;
    };
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
      tooltip = true;
    };

    "custom/startmenu" = {
      format = "";
      tooltip = true;
      "tooltip-format" = "App menu";
      on-click = "rofi -show drun";
    };

    # Waypaper launcher (single entry) close to startmenu
    "custom/waypaper" = {
      format = "";
      tooltip = true;
      "tooltip-format" = "Open Waypaper";
      on-click = "waypaper";
    };

    # Spacer between startmenu and first icon
    "custom/sep_gap_left" = {
      format = " ";
      tooltip = false;
    };

    "custom/weather" = {
      return-type = "json";
      exec = "sh -lc 'WEATHER_ICON_STYLE=emoji WEATHER_TOOLTIP_MARKUP=1 ${pythonWithRequests}/bin/python3 ~/.config/waybar/scripts/Weather.py'";
      interval = 600;
      tooltip = true;
    };

    "custom/notification" = {
      tooltip = false;
      format = "{icon} {}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t";
      escape = true;
    };

    pulseaudio = {
      format = "{icon} {volume}% {format_source}";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = " {icon} {format_source}";
      format-muted = " {format_source}";
      format-source = " {volume}%";
      format-source-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = ["" "" ""];
      };
      on-click = "pavucontrol";
    };

    "custom/power" = {
      format = " ⏻ ";
      tooltip = true;
      "tooltip-format" = "Power menu: Logout / Reboot / Shutdown";
      "on-click" = "~/.config/waybar/scripts/power-menu-niri.sh";
      "on-click-right" = "~/.config/waybar/scripts/power-menu-niri.sh";
    };
  };

  configJson = builtins.toJSON [barCfg];

  # Same style as Tony's, reused 1:1
  styleCss = ''
    @define-color bg    #1a1b26;
    @define-color fg    #a9b1d6;
    @define-color blk   #32344a;
    @define-color red   #f7768e;
    @define-color grn   #9ece6a;
    @define-color ylw   #e0af68;
    @define-color blu   #7aa2f7;
    @define-color mag   #ad8ee6;
    @define-color cyn   #0db9d7;
    @define-color brblk #444b6a;
    @define-color white #ffffff;

    * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 16px;
        font-weight: bold;
    }

    window#waybar {
        background-color: @bg;
        color: @fg;
    }

    #workspaces button {
        padding: 0 6px;
        color: @cyn;
        background: transparent;
        border-bottom: 3px solid @bg;
    }
    #workspaces button.active {
        color: @cyn;
        border-bottom: 3px solid @mag;
    }
    #workspaces button.empty {
        color: @white;
    }
    #workspaces button.empty.active {
        color: @cyn;
        border-bottom: 3px solid @mag;
    }

    #workspaces button.urgent {
        background-color: @red;
    }

    button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #ffffff;
    }

    #clock,
    #custom-sep,
    #battery,
    #cpu,
    #memory,
    #disk,
    #network,
    #tray,
    #pulseaudio,
    #idle_inhibitor,
    #custom-notification,
    #custom-power {
        padding: 0 8px;
        color: @white;
    }
    /* Rounded, raised bottom effect for center/right modules */
    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #network,
    #tray,
    #pulseaudio,
    #idle_inhibitor,
    #custom-notification,
    #custom-power {
        border-bottom-left-radius: 10px;
        border-bottom-right-radius: 10px;
        box-shadow: inset 0 -2px rgba(255,255,255,0.07);
    }
    /* Tighten spacing between the two QS buttons */
    #group-qs_wallpapers { margin: 0; padding: 0; }

    /* Make QS icons match startmenu color and background (bright green) */
    /* Start menu stays bright green; QS icons switch to clock blue (@cyn) */
    #custom-startmenu {
        color: @grn;
        background: transparent;
        font-size: 21px; /* ~30% larger than base 16px */
    }
    #custom-qs_wallpapers_apply,
    #custom-qs_vid_wallpapers_apply {
        color: @cyn; /* match clock color */
        background: transparent;
        font-size: 21px; /* ~30% larger than base 16px */
    }
    /* Prevent QS icons from being clipped; add a tiny internal pad */
    #custom-qs_wallpapers_apply,
    #custom-qs_vid_wallpapers_apply {
        padding: 0 2px;
        min-width: 20px;
    }
    #custom-startmenu { margin-right: 6px; }

    #custom-sep {
        color: @brblk;
    }
    /* Width for gap spacer between QS icons */
    #custom-sep_gap { padding: 0 1px; }
    #custom-sep_gap_left { padding: 0 2px; }

    #clock {
        color: @cyn;
        border-bottom: 4px solid @cyn;
    }

    #battery {
        color: @mag;
        border-bottom: 4px solid @mag;
    }

    #disk {
        color: @ylw;
        border-bottom: 4px solid @ylw;
    }

    #memory {
        color: @mag;
        border-bottom: 4px solid @mag;
    }

    #cpu {
        color: @grn;
        border-bottom: 4px solid @grn;
    }

    #network {
        color: @blu;
        border-bottom: 4px solid @blu;
    }

    #network.disconnected {
        background-color: @red;
    }

    #pulseaudio {
        color: @blu;
        border-bottom: 4px solid @blu;
    }

    /* Center the idle_inhibitor icon within its pill */
    #idle_inhibitor {
        /* Center visually via symmetric padding + fixed min width */
        padding-left: 10px;
        padding-right: 10px;
        min-width: 26px;            /* keep a consistent hit area */
        border-bottom: 4px solid @brblk; /* default raised strip */
        border-bottom-left-radius: 10px;
        border-bottom-right-radius: 10px;
    }
    #idle_inhibitor label {
        margin: 0;                  /* remove any label offset */
        padding: 0;
    }

    #idle_inhibitor.deactivated {
        color: @red;
        border-bottom: 4px solid @red;
    }

    #idle_inhibitor.activated {
        color: @grn;
        border-bottom: 4px solid @grn;
        margin-right: 5px;
    }

    #custom-notification {
        color: @grn; /* default green */
        border-bottom: 4px solid @grn;
    }
    /* Turn red on new alerts */
    #custom-notification.notification,
    #custom-notification.dnd-notification,
    #custom-notification.inhibited-notification {
        color: @red;
        border-bottom: 4px solid @red;
    }
    /* Add subtle raised effect to center modules too */
    #custom-notification,
    #idle_inhibitor {
        box-shadow: inset 0 -3px @brblk;
    }

    #tray {
        background-color: @bg; /* match bar background */
        border-bottom: 4px solid @brblk; /* restore raised strip */
        border-bottom-left-radius: 10px;
        border-bottom-right-radius: 10px;
    }

    #custom-power {
        color: @red;
        border-bottom: 4px solid @red;
    }
  '';

  waybarNiriWrapper = pkgs.writeShellScriptBin "waybar-niri" ''
    exec ${pkgs.waybar}/bin/waybar -c "$HOME/.config/waybar/niri-config.jsonc" -s "$HOME/.config/waybar/niri-style.css"
  '';
in {
  # Install helper wrapper to run Niri-specific Waybar
  home.packages = [waybarNiriWrapper];

  # Deploy scripts used by the bar
  home.file =
    builtins.listToAttrs
    (
      map
      (name: {
        name = ".config/waybar/scripts/" + name;
        value = {
          source = "${scriptsDir}/${name}";
          executable = true;
        };
      })
      scripts
    )
    // {
      ".config/waybar/scripts/power-menu-niri.sh" = {
        source = ./scripts/power-menu-niri.sh;
        executable = true;
      };
    };

  # Deploy Niri-specific Waybar config and style
  xdg.configFile."waybar/niri-config.jsonc".text = configJson;
  xdg.configFile."waybar/niri-style.css".text = styleCss;
}
