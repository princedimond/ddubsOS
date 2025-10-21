{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel
  ];
}
