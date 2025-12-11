{inputs, ...}: {
  imports = [
    ./boot.nix
    ./cachix.nix
    ./flatpak.nix
    ./fonts.nix
    ./global-packages.nix
    ./glances-server.nix
    ./hardware.nix
    ./printing.nix
    ./quickshell.nix
    ./ly.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./req-packages.nix
    ./proxmox-backup-client.nix
    ./sddm.nix
    ./security.nix
    ./session-env.nix
    ./services.nix
    ./steam.nix
    ./stylix.nix
    ./syncthing.nix
    ./system.nix
    ./sway-session.nix
    ./thunar.nix
    ./user.nix
    ./virtualisation.nix
    ./xserver.nix
    ./xdg-portal.nix
    inputs.stylix.nixosModules.stylix

    # Apps modules
    ../apps/warp-terminal-current.nix
  ];

  # Enable warp-terminal-current globally on all hosts
  programs.warp-terminal-current.enable = true;

  # This override was done when dvdauthor failed to build
  # Disbling but leaving this in place in case it occurs again
  # Since more than once it has failed to build 7/30/25

  # nixpkgs.overlays = [
  #  (final: prev: {
  #    dvdauthor = prev.dvdauthor.overrideAttrs (oldAttrs: {
  #      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.gettext];
  #    });
  #  })
  #];
}
