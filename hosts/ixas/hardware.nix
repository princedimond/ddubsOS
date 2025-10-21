{ config
, lib
, modulesPath
, pkgs
, # Still keep pkgs here as it's a standard argument, even if not directly used in this snippet anymore
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    # Reduce swapping
    kernel.sysctl."vm.swappiness" = "10";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f08cdfec-87e8-4454-bbdc-8080a139c7ed";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C635-4F52";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/mnt/nas" = {
      device = "192.168.40.11:/volume1/DiskStation54TB";
      fsType = "nfs";
      options = [ "rw" "soft" "tcp" "bg" "_netdev" ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/326ac53b-df5e-4c85-8c81-a9f911a52cb1"; }
  ];

  # Configure the Firewall to trust the bridge
  networking.firewall = {
    enable = true;
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
