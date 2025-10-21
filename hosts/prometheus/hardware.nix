{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      #"video=HDMI-A-1:e" # Enable HDMI-A-1
      #"video=eDP-1:d" # Disable laptop display (eDP-1)  #disable when docked
    ];
    # Reduce swapping
    kernel.sysctl."vm.swappiness" = "10";
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/3b294d68-ae1e-4253-a967-92aa3613a28e";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/B436-3EE8";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/mnt/nas" = {
      device = "192.168.40.11:/volume1/DiskStation54TB";
      fsType = "nfs";
      options = [
        "rw"
        "bg"
        "soft"
        "tcp"
        "_netdev"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/11d22209-f01c-4293-9529-e81705e81138"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  #  environment.etc."resolv.conf".text = ''
  #  domain homelan.net
  #  search homelan.net
  #  nameserver 192.168.40.3
  #  nameserver 8.8.8.8
  #  options ndots:0
  #'';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
