{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    assaultcube
    openarena
    nvtopPackages.amd
    libreoffice-fresh
    lmstudio
  ];
}
