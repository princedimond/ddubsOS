{...}: {
  # Override the system autostart entry for COSMIC Initial Setup so it only runs
  # inside the COSMIC desktop (and not in Hyprland or other sessions).
  # The system file is at /run/current-system/sw/etc/xdg/autostart/com.system76.CosmicInitialSetup.desktop
  # Writing a file with the same name under ~/.config/autostart overrides it per XDG spec.
  xdg.configFile."autostart/com.system76.CosmicInitialSetup.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=COSMIC Initial Setup
    Exec=cosmic-initial-setup
    # Restrict to the COSMIC desktop only; prevents launch under Hyprland
    OnlyShowIn=COSMIC;
    X-GNOME-Autostart-enabled=true
  '';
}
