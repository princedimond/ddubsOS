{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    assaultcube
    nvtopPackages.amd
    onlyoffice-desktopeditors
  ];
}
