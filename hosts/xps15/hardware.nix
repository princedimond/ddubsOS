{ config
, lib
, modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #./nvidia-offload.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      "video=HDMI-A-1:e" # Enable HDMI-A-1
      "video=eDP-1:d" # Disable laptop display (eDP-1)
    ];
    # Reduce swapping
    kernel.sysctl."vm.swappiness" = "10";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/889ee0eb-5978-42d0-8074-ca630789686e";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/DEB1-2B73";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    "/mnt/nas" = {
      device = "192.168.40.11:/volume1/DiskStation54TB";
      fsType = "nfs";
      options = [ "rw" "bg" "soft" "tcp" "_netdev" ];
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/2698ec5d-4379-4407-9350-46c36ff083ea"; }
  ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s20f0u2u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp62s0u1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
