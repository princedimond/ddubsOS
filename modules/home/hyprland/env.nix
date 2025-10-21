{ host, ... }:
let
  _hostVars = import ../../../hosts/${host}/variables.nix;
in {
  wayland.windowManager.hyprland.settings = {
    env = [
      "NIXOS_OZONE_WL, 1"
      "NIXPKGS_ALLOW_UNFREE, 1"
      "XDG_CURRENT_DESKTOP, Hyprland"
      "XDG_SESSION_TYPE, wayland"
      "XDG_SESSION_DESKTOP, Hyprland"
      "GDK_BACKEND, wayland, x11"
      "CLUTTER_BACKEND, wayland"
      "QT_QPA_PLATFORM=wayland;xcb"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
      "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
      "SDL_VIDEODRIVER, wayland"
      "MOZ_ENABLE_WAYLAND, 1"
      "ELECTRON_OZONE_PLATFORM_HINT,wayland"
      "BEMENU_BACKEND, wayland"
      "BEMENU_OPTS, -c -l 10 -W 0.2 -H 20 --fn 'JetBrains Mono 19'"
      "GDK_SCALE,1"
      "QT_SCALE_FACTOR,1"
      "EDITOR,nvim"
      # Set default terminal for CLI apps like yazi
      # Otherwise they load in xterm from rofi menu
      "TERMINAL,kitty"
      "XDG_TERMINAL_EDITOR,kitty"
      # NVIDIA Hybrid Offload settings
      "__NV_PRIME_RENDER_OFFLOAD,1"
      "__NV_PRIME_RENDER_OFFLOAD_PROVIDER,NVIDIA_OFFLOAD"
      # Optional need testing
      #"__GLX_VENDOR_LIBRARY_NAME,nvidia"
      # "WLR_RENDERER,nvidia"
    ];
  };
}
