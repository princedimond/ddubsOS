{pkgs, ...}: {
  # Meeded by LACT GPU util
  services.lact.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    assaultcube
    onlyoffice-desktopeditors
    lact
    nvtopPackages.amd
  ];
}
