{ ... }:
{
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-35.7.5"
  ];
}
