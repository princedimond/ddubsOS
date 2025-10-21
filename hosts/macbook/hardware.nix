{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "sd_mod" "sr_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel" "wl"];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/76578083-3fcc-4e83-a1ad-d766421426b6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A85D-A352";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/mnt/nas" = {
    device = "192.168.40.11:/volume1/DiskStation54TB";
    fsType = "nfs";
    options = ["rw" "soft" "bg" "tcp" "_netdev"];
  };
  swapDevices = [
    {device = "/dev/disk/by-uuid/dbee8e0d-6f7d-4a30-8bf2-ce789548bfa9";}
  ];

  networking.useDHCP = lib.mkDefault true;

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
