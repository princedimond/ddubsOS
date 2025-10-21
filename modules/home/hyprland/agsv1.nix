{ ... }: {
  home.file = {
    ".config/ags" = {
      source = ./ags;
      recursive = true;
    };
    ".config/waybar/wallust/colors-waybar.css".source = ./ags/colors-waybar.css;
    ".config/rofi/.current_wallpaper".source = ./ags/current_wallpaper;
  };
}
