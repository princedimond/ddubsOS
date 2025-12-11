{
  pkgs,
  lib,
  host,
  config,
  ...
}: {
  # Base packages useful for Sway sessions
  home.packages = with pkgs; [
    sway
    swaybg
    swaylock
    waybar
    grim
    slurp
    wl-clipboard
    wtype
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    sakura
    autotiling-rs
    polkit_gnome
    jq
  ];

  # Install Sway config directory if you want to manage it here later.
  # For now this file focuses on Waybar integration for Sway.

  imports = [./sway/waybar-sway.nix];

  # XDG portals for Sway (screen sharing, etc.)
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk];
      configPackages = [pkgs.sway];
    };
  };

  # Install Sway config files
  xdg.configFile = {
    "sway/config" = {source = ./sway/files/config;};
    "sway/config_cuerdos" = {source = ./sway/files/config_cuerdos;};
    "sway/keyboard_config" = {source = ./sway/files/keyboard_config;};
    "sway/sway_keyboard.sh" = {
      source = ./sway/files/sway_keyboard.sh;
      executable = true;
    };

    # Waybar scripts used by Sway bar
    "waybar/scripts/sway-power-menu.sh" = {
      source = ./sway/files/waybar-scripts/power-menu.sh;
      executable = true;
    };
    "waybar/scripts/ws.sh" = {
      source = ./sway/files/waybar-scripts/ws.sh;
      executable = true;
    };
  };

  # Optional: environment hint so helper scripts know sway is enabled
  home.sessionVariables.QS_HAS_SWAY = "1";

  # Start a polkit agent in the user session so power actions can be authorized
  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "Polkit authentication agent (GNOME)";
      PartOf = ["sway-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["sway-session.target"];};
  };
}
