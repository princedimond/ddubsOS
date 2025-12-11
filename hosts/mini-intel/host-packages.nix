{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    #kdePackages.kdenlive
    assaultcube
    handbrake
    onlyoffice-desktopeditors
    nvtopPackages.intel
  ];
}
