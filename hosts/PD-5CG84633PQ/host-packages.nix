{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # You can add software packages specific to this host here
    audacity
    lunacy
    anytype
    logseq
    notion-app-enhanced
    github-desktop
    gitkraken
    # nvtop great tool for AMD/Intel/NVIDIA GPUs
    # takes time to build and upgrade
    # Moved here to make it optional
    #mvtopPackages.full
  ];
}
