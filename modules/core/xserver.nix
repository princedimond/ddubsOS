{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) keyboardLayout gnomeEnable cosmicEnable bspwmEnable;
in
{
  # Enable desktops only when requested via host variables
  services.desktopManager.gnome.enable = gnomeEnable;
  services.desktopManager.cosmic.enable = cosmicEnable;
  # Explicitly do not enable cosmic-greeter; SDDM is our DM
  services.displayManager.cosmic-greeter.enable = false;
  services.displayManager.defaultSession = "hyprland";

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
      windowManager.bspwm.enable = bspwmEnable;
      # Disabled for now, converting to NIX format
      # But it's broken. Polybar and rofi overwrites system rofi
    };
  };
}
