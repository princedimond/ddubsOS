{ config, lib, ... }:
let
  # Point writable config at the repository path (no rebuild needed to edit)
  repoHyprpanel = "${config.home.homeDirectory}/ddubsos/modules/home/hyprpanel";
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  # Replace copy-on-activation with an out-of-store symlink for writable config
  xdg.configFile."hyprpanel" = {
    source = symlink repoHyprpanel;
    recursive = true; # directory symlink
  };

  # Keep installing helper scripts into ~/.local/bin
  home.file = {
    ".local/bin/" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
