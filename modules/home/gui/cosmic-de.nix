# Author: Don Williams (aka ddubs)
# Created: 2025-08-27
# Project: git@gitlab.com:dwilliam62/ddubsos

{ pkgs, ... }: {
  # COSMIC user-level module
  # System enablement is handled in modules/core/xserver.nix via cosmicEnable.
  # This module installs commonly used COSMIC apps for the user.

  home.packages = with pkgs; [
    # Core user applications and UI components
    cosmic-term
    cosmic-settings
    cosmic-files
    cosmic-edit
    cosmic-randr
    cosmic-idle
    cosmic-comp
    cosmic-osd
    cosmic-bg
    cosmic-applets
    cosmic-store
    cosmic-player
    cosmic-session

    # Protocols, icons, workspaces, daemons
    cosmic-protocols
    cosmic-icons
    cosmic-workspaces-epoch
    cosmic-settings-daemon

    # Assets and integrations
    cosmic-wallpapers
    cosmic-screenshot
    xdg-desktop-portal-cosmic
  ];
}

