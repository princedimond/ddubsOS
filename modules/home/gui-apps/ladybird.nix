{
  pkgs,
  lib,
  ...
}: let
  lb = pkgs.ladybird;
  # Wrapper that unsets Qt theming env so Stylix/qtct/kvantum do not override Ladybird's own theme
  ladybirdWrapper = pkgs.writeShellScriptBin "ladybird" ''
    #!/usr/bin/env bash
    # Remove system-wide Qt theming variables for this process only
    unset QT_STYLE_OVERRIDE
    unset QT_QPA_PLATFORMTHEME
    unset QT_QUICK_CONTROLS_STYLE
    exec -a ladybird "${lb}/bin/ladybird" "$@"
  '';
in {
  # Install Ladybird and the wrapper (wrapper shadows the store binary via PATH precedence)
  home.packages = [lb ladybirdWrapper];

  # Override desktop entry so desktop launches use our wrapper
  xdg.desktopEntries.ladybird = {
    name = "Ladybird";
    genericName = "Web Browser";
    comment = "Ladybird browser (launch without system Qt theming)";
    exec = "ladybird %U";
    terminal = false;
    categories = ["Network" "WebBrowser"];
    type = "Application";
  };
}
