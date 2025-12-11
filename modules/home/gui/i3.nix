{
  pkgs,
  lib,
  ...
}: {
  # We do not enable Home Manager's i3 module to avoid config file conflicts.
  # i3 is provided via packages and config files are managed below.

  # Environment flag for tooling to detect i3 presence
  home.sessionVariables = {
    QS_HAS_I3 = "1";
  };

  # Packages referenced by the configuration and scripts
  home.packages = with pkgs; [
    i3
    i3status
    i3lock
    rofi
    dunst
    picom
    pamixer
    xorg.xbacklight
    flameshot
    feh
    variety
    libnotify
    xdotool
    sxhkd
    polybar
  ];

  # Copy i3 config files (Phase 1: raw copies). Phase 2 will port to Nix options.
  home.file = {
    ".config/i3/config".source = ./i3/config;
    ".config/i3/rules.conf".source = ./i3/rules.conf;
    ".config/i3/workspaces.conf".source = ./i3/workspaces.conf;

    # Rofi themes used by the config
    ".config/i3/rofi/config.rasi".source = ./i3/rofi/config.rasi;
    ".config/i3/rofi/power.rasi".source = ./i3/rofi/power.rasi;
    ".config/i3/rofi/keybinds.rasi".source = ./i3/rofi/keybinds.rasi;

    # Dunst
    ".config/i3/dunst/dunstrc".source = ./i3/dunst/dunstrc;

    # Picom
    ".config/i3/picom/picom.conf".source = ./i3/picom/picom.conf;

    # Sxhkd keybinds kept for Phase 2 parser (reference only)
    ".config/i3/sxhkd/sxhkdrc".source = ./i3/sxhkd/sxhkdrc;

    # Scripts
    ".config/i3/scripts/changevolume" = {
      source = ./i3/scripts/changevolume;
      executable = true;
    };
    ".config/i3/scripts/help" = {
      source = ./i3/scripts/help;
      executable = true;
    };
    ".config/i3/scripts/autostart.sh" = {
      source = ./i3/scripts/autostart.sh;
      executable = true;
    };
    ".config/i3/scripts/power" = {
      source = ./i3/scripts/power;
      executable = true;
    };
    ".config/i3/scripts/scratchpad" = {
      source = ./i3/scripts/scratchpad;
      executable = true;
    };

    # Polybar
    ".config/i3/polybar/config.ini".source = ./i3/polybar/config.ini;
    ".config/i3/polybar/polybar-i3" = {
      source = ./i3/polybar/polybar-i3;
      executable = true;
    };
  };
}
