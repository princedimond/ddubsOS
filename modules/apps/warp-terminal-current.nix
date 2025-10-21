{ lib, pkgs, config, ... }:

with lib;
with lib.attrsets;

let
  cfg = config.programs.warp-terminal-current;
in
{
  options.programs.warp-terminal-current = {
    enable = mkEnableOption "Warp Terminal (current/bleeding-edge version)";
    
    waylandSupport = mkOption {
      type = types.bool;
      default = false;  # Default to X11 for better compatibility
      description = "Enable Wayland support for Warp Terminal. Set to false to use X11 backend.";
    };
    
    package = mkOption {
      type = types.package;
      default = pkgs.warp-bld;
      description = "The warp-bld package to use";
    };
    
    desktopName = mkOption {
      type = types.str;
      default = "Warp-bld";
      description = "Name to display in application launchers";
    };
    
    iconName = mkOption {
      type = types.str;
      default = "warp-terminal-bld";
      description = "Icon name for the application";
    };
  };

  config = mkIf cfg.enable {
    # Install both the bleeding-edge version AND ensure stable is available
    environment.systemPackages = [ 
      cfg.package  # warp-bld package
      pkgs.warp-terminal  # stable version from nixpkgs
    ];
    
    # Create a simple custom icon for warp-bld to distinguish it in GUI launchers
    environment.etc."icons/hicolor/scalable/apps/warp-terminal-bld.svg".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
        <rect width="64" height="64" rx="8" fill="#1e1e2e" stroke="#89b4fa" stroke-width="2"/>
        <text x="32" y="30" text-anchor="middle" fill="#89b4fa" font-family="monospace" font-weight="bold" font-size="10">WARP</text>
        <text x="32" y="45" text-anchor="middle" fill="#f38ba8" font-family="monospace" font-weight="bold" font-size="8">BLD</text>
        <rect x="48" y="8" width="12" height="8" rx="2" fill="#f38ba8"/>
        <text x="54" y="14" text-anchor="middle" fill="#1e1e2e" font-family="monospace" font-size="6">β</text>
      </svg>
    '';
    
    
    # Create desktop entry with distinct name and icon for GUI launcher
    environment.etc."applications/warp-bld.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Name=${cfg.desktopName}
      GenericName=Terminal Emulator (Bleeding Edge)
      Comment=Rust-based terminal (Latest/Bleeding Edge Version)
      Exec=warp-bld
      Icon=warp-terminal
      Terminal=false
      Type=Application
      Categories=System;TerminalEmulator;Utility;
      StartupWMClass=warp
      Keywords=terminal;shell;prompt;command;commandline;bleeding;edge;current;
      StartupNotify=true
      MimeType=application/x-terminal-emulator;
      NoDisplay=false
      Actions=
    '';

    # Configure Wayland/X11 support with fallback for compatibility
    environment.sessionVariables = {
      # Set Wayland preference but allow fallback
      WARP_ENABLE_WAYLAND = if cfg.waylandSupport then "1" else "0";
    } // (optionalAttrs (!cfg.waylandSupport) {
      # Force X11 backend for systems with Wayland issues
      WINIT_UNIX_BACKEND = "x11";
      GDK_BACKEND = "x11";
    });
    
    # Update desktop and icon caches after installing
    system.activationScripts.warp-bld-desktop = {
      text = ''
        # Update desktop database
        if command -v update-desktop-database >/dev/null 2>&1; then
          ${pkgs.desktop-file-utils}/bin/update-desktop-database -q /etc/applications || true
        fi
        
        # Update icon cache
        if command -v gtk-update-icon-cache >/dev/null 2>&1; then
          ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t /etc/icons/hicolor 2>/dev/null || true
        fi
        
        # For KDE environments
        if command -v kbuildsycoca5 >/dev/null 2>&1; then
          kbuildsycoca5 --noincremental 2>/dev/null || true
        fi
      '';
      deps = [];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ ];
  };
}
