{ pkgs, ... }:
{
  # Window routing and rules
  window-rules = [
    # Picture-in-Picture floats
    {
      matches = [ { app-id = "zen"; title = "^Picture-in-Picture$"; } ];
      open-floating = true;
    }

    # Kitty default width
    {
      matches = [ { app-id = "kitty"; } ];
      default-column-width.proportion = 0.75;
    }

    # Bitwarden capture block
    {
      matches = [ { app-id = "Bitwarden"; } ];
      block-out-from = "screen-capture";
    }

    # Floating windows styling
    {
      matches = [ { is-floating = true; } ];
      geometry-corner-radius = {
        top-left = 10.0;
        top-right = 10.0;
        bottom-left = 10.0;
        bottom-right = 10.0;
      };
      clip-to-geometry = true;
      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = { x = 0; y = 5; };
        draw-behind-window = true;
        color = "#00000070";
      };
    }

    # WRK workspace routing
    {
      matches = [ { app-id = "pragtical"; } { app-id = "zen"; } ];
      open-on-workspace = "WRK";
      default-column-width.proportion = 1.0;
    }

    # MUS workspace routing
    {
      matches = [ { app-id = "musikcube"; } ];
      open-on-workspace = "MUS";
      default-column-width.proportion = 1.0;
    }

    # Active/inactive opacity
    { matches = [ { is-active = false; } ]; opacity = 0.95; }
    { matches = [ { is-active = true; } ]; opacity = 1.0; }

    # Browsers workspace routing (common variants)
    {
      matches = [
        { app-id = "google-chrome-stable"; }
        { app-id = "google-chrome"; }
        { app-id = "chrome"; }
        { app-id = "chromium"; }
        { app-id = "chromium-browser"; }
      ];
      open-on-workspace = "Browsers";
    }

    # Discord workspace routing
    {
      matches = [
        { app-id = "discord"; }
        { app-id = "discord-canary"; }
        { app-id = "vesktop"; }
      ];
      open-on-workspace = "Discord";
    }

    # Signal workspace routing (both cases)
    {
      matches = [ { app-id = "Signal"; } { app-id = "signal"; } ];
      open-on-workspace = "Signal";
    }
  ];

  # Ensure wallpaper layer is placed behind backdrop
  layer-rules = [
    {
      matches = [ { namespace = "swww-daemon"; } ];
      place-within-backdrop = true;
    }
  ];
}

