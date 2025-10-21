{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wayfire
    wofi
    yad
    swaybg
  ];

  home.file = {
    ".config/wayfire" = {
      source = ./wayfire;
      recursive = true;
    };
    ".config/wayfire.ini".source = ./wayfire/wayfire.ini;
    ".config/wayfire-azerty.ini".source = ./wayfire/wayfire-azerty.ini;
  };
}
