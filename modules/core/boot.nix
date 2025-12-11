{
  pkgs,
  config,
  ...
}: {
  boot = {
    # Use the standard NixOS latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # v4l2loopback for OBS virtual camera and similar tools
    # DISABLED: v4l2loopback 0.15.1 incompatible with kernel 6.18 (v4l2_fh API changed)
    # Re-enable when nixpkgs updates v4l2loopback or we have a patch
    kernelModules = [];
    extraModulePackages = [];

    kernel.sysctl = {"vm.max_map_count" = 2147483642;};
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    plymouth.enable = false;
  };
}
