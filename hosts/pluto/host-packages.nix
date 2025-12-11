{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # You can add software packages specific to this host here
    audacity
    onlyoffice-desktopeditors
    #mvtopPackages.full
  ];
}
