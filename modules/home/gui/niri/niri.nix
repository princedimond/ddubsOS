{ pkgs, lib, ... }:
{
  # Install Niri, Waybar, and appropriate XDG portals for a Wayland compositor
  home.packages = with pkgs; [
    niri
    waybar
    udiskie
    xwayland-satellite
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    swww
  ];

  # Provide Niri + portal stack via Home Manager
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    portal = {
      enable = true;
      # wlr portal works well with Niri (Smithay-based)
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      # Register Niri as a desktop for portal config
      configPackages = [ pkgs.niri ];
    };
  };

  # Write KDL config by composing modular KDL snippets (fallback until HM exposes programs.niri)
  xdg.configFile."niri/config.kdl".text = lib.concatStringsSep "\n\n" [
    (builtins.readFile ./kdl/00-settings.kdl)
    (builtins.readFile ./kdl/10-autostart.kdl)
    (builtins.readFile ./kdl/20-binds.kdl)
    (builtins.readFile ./kdl/30-rules.kdl)
  ];
  
  # Set environment variable for qs-keybinds to know niri is enabled
  home.sessionVariables = {
    QS_HAS_NIRI = "1";
  };
}
