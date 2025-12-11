{
  config,
  lib,
  pkgs,
  ...
}: let
  # Path in the repo where your writable Zed config lives
  repoZedConfig = "${config.home.homeDirectory}/ddubsos/modules/home/editors/zed-config";
  symlink = config.lib.file.mkOutOfStoreSymlink;
in {
  # Install Zed via Home Manager
  home.packages = [pkgs.zed-editor];

  # Replace copy/backup activation with an out-of-store symlink for writable config
  xdg.configFile."zed" = {
    source = symlink repoZedConfig;
    recursive = true; # directory symlink
  };
}
