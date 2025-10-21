{
  lib,
  config,
  specialArgs,
  ...
}:
with lib;
let
  cfg = config.drivers.nvidia;
  isExceptionHost = specialArgs.host == "xps15"; # Check if the host is the exception
in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = !isExceptionHost; # True for all hosts except xps15
      nvidiaSettings = true;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package =
        if isExceptionHost then
          config.boot.kernelPackages.nvidiaPackages.stable # Stable for xps15
        else
          config.boot.kernelPackages.nvidiaPackages.beta; # Beta for others
    };
  };
}
