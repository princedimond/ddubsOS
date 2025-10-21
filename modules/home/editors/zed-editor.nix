{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Path in the repo where your writable Zed config lives
  repoZedConfig = "${config.home.homeDirectory}/ddubsos/modules/home/editors/zed-config";
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  # Keep the zed-editor source override if needed
  /*
    nixpkgs.overlays = [
      (final: prev: {
        zed-editor = prev.zed-editor.overrideAttrs (old: {
          src = prev.fetchFromGitHub {
            owner = "zed-industries";
            repo = "zed";
            rev = "v0.202.5"; # keep in sync with the package version
            sha256 = "sha256-Q7Ord+GJJcOCH/S3qNwAbzILqQiIC94qb8V+JkzQqaQ=";
            fetchSubmodules = true;
          };
        });
      })
    ];
  */

  # Install Zed via Home Manager
  home.packages = [ pkgs.zed-editor ];

  # Replace copy/backup activation with an out-of-store symlink for writable config
  xdg.configFile."zed" = {
    source = symlink repoZedConfig;
    recursive = true; # directory symlink
  };
}
