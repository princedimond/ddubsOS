{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    assaultcube
    nvtopPackages.amd
    libreoffice-fresh
    lmstudio
    openarena
    ollama
  ];
}
