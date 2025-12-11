{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    #urbanterror
    #unvanquished
    #xonotic
    assaultcube
    onlyoffice-desktopeditors
    nvtopPackages.full
  ];

  environment.variables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA_OFFLOAD";
  };
}
