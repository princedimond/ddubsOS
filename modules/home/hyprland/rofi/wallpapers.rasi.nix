# Installs wallpapers.rasi into ~/.config/rofi/
{ ... }: {
  home.file = {
    ".config/rofi/wallpapers.rasi" = {
      source = ./wallpapers.rasi;
    };
  };
}

