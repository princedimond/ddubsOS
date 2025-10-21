{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    kdePackages.kdenlive
    xonotic
    assaultcube
    davinci-resolve
    nvtopPackages.nvidia
    libreoffice-fresh
    lmstudio
    ollama
    openarena
    lincity_ng
  ];
}
