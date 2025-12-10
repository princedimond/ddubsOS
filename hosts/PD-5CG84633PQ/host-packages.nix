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
    bitwarden-desktop
    affine
    ferdium
    meld
    orca-slicer
    rpi-imager
    warp-terminal
    microsoft-edge
    xarchiver
    nss
    nss_latest
    # nvtop great tool for AMD/Intel/NVIDIA GPUs
    # takes time to build and upgrade
    # Moved here to make it optional
    #mvtopPackages.full
  ];
}
