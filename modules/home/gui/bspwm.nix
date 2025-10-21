{pkgs, ...}: {
  imports = [
    ./bspwm/bspwm.nix
    ./bspwm/sxhkd.nix
    ./bspwm/picom/picom.nix
    ./bspwm/polybar/polybar.nix
  ];
  
  # Set environment variable for qs-keybinds to know bspwm is enabled
  home.sessionVariables = {
    QS_HAS_BSPWM = "1";
  };

  home.packages = with pkgs; [
    arandr
    clipmenu
    dunst
    dmenu
    feh
    flameshot
    polkit_gnome
    scrot
    variety
    volumeicon
  ];
}
