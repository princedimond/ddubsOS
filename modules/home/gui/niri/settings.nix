{ pkgs, ... }:
{
  prefer-no-csd = true;

  environment = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORM = "wayland";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_WAYLAND_DISABLE_WINDOW_DECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    CLUTTER_BACKEND = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    ELECTRON_ENABLE_HARDWARE_ACCELERATION = "1";
    XDG_CURRENT_DESKTOP = "Niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Niri";
    DISPLAY = ":0";
  };

  input = {
    keyboard.xkb.layout = "us";
    touchpad = {
      tap = true;
      dwt = true;
      accel-speed = 0.4;
      accel-profile = "flat";
      scroll-method = "two-finger";
      tap-button-map = "left-right-middle";
      scroll-factor = 0.7;
    };
    focus-follows-mouse.enable = true;
  };

  overview.zoom = 0.65;

  layout = {
    gaps = 4;
    background-color = "transparent";
    default-column-width.proportion = 0.75;
    border = {
      width = 4;
      active-color = "#ffc87f";
      inactive-color = "#505050";
    };
    shadow = {
      enable = true;
      softness = 30;
      spread = 5;
      offset = { x = 0; y = 5; };
      color = "#000000";
    };
    struts = { left = 10; right = 10; top = 10; bottom = 10; };
  };

  workspaces = {
    "Browsers" = {};
    "Discord" = {};
    "Signal" = {};
    "WRK" = {};
    "MUS" = {};
  };
}

