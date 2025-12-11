{pkgs, ...}: {
  # Keep rules as raw KDL text for fidelity with upstream syntax
  windowRulesKdl = ''
    // All windows default geometry
    window-rule {
      geometry-corner-radius 4
      clip-to-geometry true
    }

    // Picture-in-Picture floats
    window-rule {
      match app-id=r#"zen$"# title="^Picture-in-Picture$"
      open-floating true
    }

    // Rofi dialogs should float (small power menu, etc.)
    window-rule {
      match app-id=r#"(?i)^rofi$"#
      open-floating true
      default-column-width { proportion 0.3; }
    }

    // Kitty default width
    window-rule {
      match app-id="kitty"
      default-column-width { proportion 0.75; }
    }

    // Bitwarden capture block
    window-rule {
      match app-id=r#"^Bitwarden$"#
      block-out-from "screen-capture"
    }

    // Floating windows styling
    window-rule {
      match is-floating=true
      geometry-corner-radius 10
      clip-to-geometry true

      shadow {
        on
        softness 30
        spread 5
        offset x=0 y=5
        draw-behind-window true
        color "#00000070"
      }
    }

    // WRK workspace routing
    window-rule {
      match app-id="pragtical"
      match app-id="zen"
      open-on-workspace "WRK"
      default-column-width { proportion 1.0; }
    }

    // MUS workspace routing
    window-rule {
      match app-id="musikcube"
      open-on-workspace "MUS"
      default-column-width { proportion 1.0; }
    }

    // Active/inactive opacity
    window-rule {
      match is-active=false
      opacity 0.95
    }
    window-rule {
      match is-active=true
      opacity 1.0
    }

    // Browsers workspace routing (common variants)
    window-rule {
      match app-id=r#"(?i)^(google-chrome(?:-stable)?|chrome|chromium(?:-browser)?)$"#
      open-on-workspace "Browsers"
    }

    // Discord workspace routing
    window-rule {
      match app-id=r#"^(discord|discord-canary|vesktop)$"#
      open-on-workspace "Discord"
    }

    // Signal workspace routing (both cases)
    window-rule {
      match app-id=r#"(?i)^signal$"#
      open-on-workspace "Signal"
    }
  '';

  # Ensure wallpaper and quickshell layers are placed within backdrop
  layerRulesKdl = ''
    layer-rule {
      match namespace="swww-daemon"
      place-within-backdrop true
    }

    layer-rule {
      match namespace="quickshell"
      place-within-backdrop true
    }
  '';
}
