{ pkgs, lib, ... }:
let
  twin = pkgs.callPackage ../../../pkgs/twin/default.nix {};
in
{
  # Install twin for the user when this module is imported.
  home.packages = [ twin ];

  # Optional: simple wrapper to start twin server/session (documented in FAQ later if desired)
  # programs.zsh.shellAliases.twin = "twin";
}
