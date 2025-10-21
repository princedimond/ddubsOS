# ~/ddubsos/modules/home/davinci-resolve.nix
{
  pkgs,
  username,
  profile,
  ...
}: {
  # Add user to video and render groups for GPU access
  users.users.${username}.extraGroups = ["render" "video"];

  # Set the required environment variable for DaVinci Resolve.
  home-manager.users.${username} = {
    home.sessionVariables = {
      LOG4CXX_CONFIGURATION = "${pkgs.davinci-resolve}/share/resolve/configs/log-conf.xml";
    };
  };

  # Conditionally add ONLY the required driver package for the current host profile.
  # This prevents errors from trying to reference packages that don't exist
  # for a given architecture or configuration.
  environment.systemPackages =
    if profile == "nvidia" || profile == "nvidia-laptop"
    then [
      pkgs.cudatoolkit
      pkgs.ocl-icd
    ]
    else if profile == "amd"
    then [
      # pkgs.rocm-opencl-icd # This package is causing issues, commenting out for now.
      pkgs.ocl-icd
    ]
    else if profile == "intel"
    then [
      pkgs.intel-compute-runtime
      pkgs.intel-media-driver
      pkgs.intel-gpu-tools
      pkgs.vulkan-tools
      pkgs.ocl-icd
      pkgs.vaapiVdpau
    ]
    else [];
}
