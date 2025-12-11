{
  pkgs,
  lib ? pkgs.lib,
  ...
}: let
  binds = import ./bindings.nix {};
in rec {
  # KDL: hotkey-overlay { skip-at-startup }
  hotkeyOverlay = {
    skipAtStartup = true;
  };

  # KDL: prefer-no-csd
  preferNoCsd = true;

  # KDL: screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
  screenshotPath = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

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
    keyboard = {
      xkb.layout = "us";
    };
    touchpad = {
      tap = true;
      dwt = true;
      accelSpeed = 0.4;
      accelProfile = "flat";
      scrollMethod = "two-finger";
      tapButtonMap = "left-right-middle";
      scrollFactor = 0.7;
    };
    focusFollowsMouse = true;
  };

  overview = {
    zoom = 0.65;
    backdropColor = "transparent";
  };

  outputs = [
    {
      name = "eDP-1";
      mode = "1920x1080@60.000";
      scale = 1;
    }
    {
      name = "Virtual-1";
      mode = "1920x1080@60.000";
      scale = 1;
    }
    {
      name = "HDMI-A-1";
      mode = "1920x1080@60.000";
      scale = 1;
    }
  ];

  layout = {
    gaps = 4;
    backgroundColor = "transparent";
    defaultColumnWidth = {proportion = 0.75;};
    focusRing = {enable = false;};
    border = {
      width = 4;
      activeColor = "#ffc87f";
      inactiveColor = "#505050";
    };
    shadow = {
      enable = true;
      softness = 30;
      spread = 5;
      offset = {
        x = 0;
        y = 5;
      };
      color = "#000000";
    };
    struts = {
      left = 10;
      right = 10;
      top = 10;
      bottom = 10;
    };
  };

  cursor = {
    xcursorTheme = "Pop";
    xcursorSize = 24;
    hideWhenTyping = true;
    hideAfterInactiveMs = 5000;
  };

  # Switch events
  switchEvents = [
    {
      event = "lid-close";
      spawn = ["swaylock"];
    }
  ];

  # Animations block retained as text for fidelity
  animationsText = ''
    animations {
      workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
      }

      window-open {
        duration-ms 150
        curve "ease-out-quad"
      }

      window-close {
        duration-ms 150
        curve "ease-out-quad"
      }

      horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }

      window-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }

      window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }

      config-notification-open-close {
        spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
      }

      screenshot-ui-open {
        duration-ms 200
        curve "ease-out-quad"
      }
    }
  '';

  # Binds block moved to a dedicated module for reuse
  bindsText = binds.bindsText;

  workspaces = {
    "Browsers" = {};
    "Discord" = {};
    "Signal" = {};
    "WRK" = {};
    "MUS" = {};
  };
}
