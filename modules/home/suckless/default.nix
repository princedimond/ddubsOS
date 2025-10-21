{ pkgs, lib, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) dwmEnable;
  suckless-pkgs = import ./pkgs.nix { inherit pkgs; };
in
{
  # Note: This module is only imported when dwmEnable = true (see modules/home/default.nix:78)
  home.packages = with suckless-pkgs; [
    dwm
    st
    slstatus
    # scripts # managed by xdg.configFile
    pkgs.arandr
    pkgs.dunst
    pkgs.feh
    pkgs.flameshot
    pkgs.nitrogen
    pkgs.pamixer
    pkgs.picom
    pkgs.sxhkd
    pkgs.variety
    pkgs.volumeicon
  ];

  xdg.configFile."suckless/dunst/dunstrc".source = ../dwm-setup/suckless/dunst/dunstrc;
  xdg.configFile."suckless/picom/picom.conf".source = ../dwm-setup/suckless/picom/picom.conf;
  xdg.configFile."suckless/rofi".source = ../dwm-setup/suckless/rofi;
  xdg.configFile."suckless/sxhkd/sxhkdrc".source = ../dwm-setup/suckless/sxhkd/sxhkdrc;

  xdg.configFile."suckless/scripts/autostart.sh".source = ../dwm-setup/suckless/scripts/autostart.sh;
  xdg.configFile."suckless/scripts/changevolume".source = ../dwm-setup/suckless/scripts/changevolume;
  xdg.configFile."suckless/scripts/dwm-layout-menu.sh".source =
    ../dwm-setup/suckless/scripts/dwm-layout-menu.sh;
  xdg.configFile."suckless/scripts/help".source = ../dwm-setup/suckless/scripts/help;
  xdg.configFile."suckless/scripts/power".source = ../dwm-setup/suckless/scripts/power;
  xdg.configFile."suckless/scripts/redshift-off".source = ../dwm-setup/suckless/scripts/redshift-off;
  xdg.configFile."suckless/scripts/redshift-on".source = ../dwm-setup/suckless/scripts/redshift-on;
  
  # Set environment variable for qs-keybinds to know dwm is enabled
  home.sessionVariables = {
    QS_HAS_DWM = "1";
  };
}
