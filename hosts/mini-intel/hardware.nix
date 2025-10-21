{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    kernel.sysctl."vm.swappiness" = "10";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/787dc3d7-0c41-46af-9e69-52fc146a7958";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2C2B-AE41";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/mnt/nas" = {
      device = "192.168.40.11:/volume1/DiskStation54TB";
      fsType = "nfs";
      options = ["rw" "soft" "bg" "tcp" "_netdev"];
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/0caadb66-7a13-4edd-b768-40e73f638524";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
