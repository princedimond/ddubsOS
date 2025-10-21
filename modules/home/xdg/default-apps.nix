{ host, lib, ... }:
let
  # Import per-host variables
  vars = import ../../../hosts/${host}/variables.nix;

  # Use the per-host browser when set; default to google-chrome-stable
  browserKey = vars.browser or "google-chrome-stable";
  zenEnabled = vars.enableZenBrowser or false;

  # Map browser key -> desktop entry ID
  browserDesktop = {
    # Google Chrome
    "google-chrome" = "google-chrome.desktop";
    "google-chrome-stable" = "google-chrome.desktop";

    # Microsoft Edge
    "microsoft-edge" = "microsoft-edge.desktop";

    # Firefox family
    "firefox" = "firefox.desktop";
    "firefox-esr" = "firefox-esr.desktop";

    # Chromium/Vivaldi/Brave
    "chromium" = "chromium.desktop";
    "vivaldi" = "vivaldi-stable.desktop"; # adjust if package provides vivaldi.desktop on your system
    "brave" = "brave-browser.desktop";

    # Floorp
    "floorp" = "floorp.desktop";

    # Zen browser
    "zen" = "zen.desktop";
    "zen-browser" = "zen.desktop";
  };

  desktopId = browserDesktop.${browserKey} or null;
  isZen = builtins.elem browserKey [
    "zen"
    "zen-browser"
  ];

in
{
  assertions = [
    {
      assertion = desktopId != null;
      message = "Unsupported browser key '${browserKey}'. Update modules/home/xdg/default-apps.nix mapping or choose a supported value in hosts/${host}/variables.nix.";
    }
    {
      assertion = (!isZen) || zenEnabled;
      message = "browser='${browserKey}' requires enableZenBrowser = true in hosts/${host}/variables.nix so Zen is installed.";
    }
  ];

  # Declaratively manage default handlers so apps (Discord, etc.) open the chosen browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.mkIf (desktopId != null) {
      "x-scheme-handler/http" = [ desktopId ];
      "x-scheme-handler/https" = [ desktopId ];
      "text/html" = [ desktopId ];
      "application/xhtml+xml" = [ desktopId ];
    };
  };
}
