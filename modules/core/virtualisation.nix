{ pkgs, ... }: {
  # Only enable either docker or podman -- Not both
  virtualisation = {
    docker = {
      enable = true;
    };

    podman.enable = false;

    libvirtd = {
      enable = true;
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
