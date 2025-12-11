{
  pkgs,
  lib,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  incusOn =
    if builtins.hasAttr "enableIncus" vars
    then vars.enableIncus
    else false;
in {
  # Incus requires nftables; enable it when Incus is toggled on per host
  networking.nftables.enable = lib.mkIf incusOn true;

  # Only enable either docker or podman -- Not both
  virtualisation = {
    docker = {
      enable = true;
    };

    podman = {
      enable = false;
      dockerCompat = true; # provide `docker` CLI via podman-docker when Podman is used
    };

    libvirtd = {
      enable = true;
    };

    # Incus daemon and Web UI (gated by hosts/<host>/variables.nix: enableIncus)
    incus = {
      enable = incusOn;
      ui.enable = incusOn;
    };

    # Not well tested  Added by request of users
    virtualbox.host = {
      enable = false;
      enableExtensionPack = false;
    };
  };

  programs = {
    virt-manager.enable = false;
  };

  environment.systemPackages = with pkgs; [
    virt-viewer # View Virtual Machines
    lazydocker
    docker-client
  ];
}
