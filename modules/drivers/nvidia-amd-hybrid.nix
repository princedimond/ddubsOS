{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.drivers.nvidia-amd-hybrid;
in
{
  options.drivers.nvidia-amd-hybrid = {
    enable = mkEnableOption "Enable AMD iGPU + NVIDIA dGPU (Prime offload)";

    amdgpuBusID = mkOption {
      type = types.str;
      default = "PCI:5:0:0";
      description = "PCI Bus ID for AMD iGPU (amdgpuBusId)";
    };

    nvidiaBusID = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
      description = "PCI Bus ID for NVIDIA dGPU (nvidiaBusId)";
    };
  };

  config = mkIf cfg.enable {
    # Enforce kernel 6.12 when this hybrid config is selected
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true; # RTX 50xx requires the open kernel module
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;

      powerManagement.enable = true;
      powerManagement.finegrained = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = cfg.amdgpuBusID;
        nvidiaBusId = cfg.nvidiaBusID;
      };
    };
  };
}
