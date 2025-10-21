{ ... }: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Accept insecure Broadcom STA package only on macbook host
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-57-6.12.44"
  ];
}
