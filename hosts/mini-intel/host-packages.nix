{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    assaultcube
    nvtopPackages.intel
    libreoffice-fresh
    handbrake
    openarena
    nvtopPackages.intel
  ];
}
