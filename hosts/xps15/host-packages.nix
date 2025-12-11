{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    audacity
    nodejs
    assaultcube
    nvtopPackages.full
    onlyoffice-desktopeditors
  ];

  environment.variables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA_OFFLOAD";
  };
}
