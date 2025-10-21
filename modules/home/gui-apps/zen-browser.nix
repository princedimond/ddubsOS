{ pkgs, inputs, ... }:
let
  # Prefer explicit package name if available; fall back to default
  zenPkg = inputs.zen-browser.packages.${pkgs.system}.zen-browser or inputs.zen-browser.packages.${pkgs.system}.default;
in
{
  # Install Zen Browser for the user
  home.packages = [ zenPkg ];
}
