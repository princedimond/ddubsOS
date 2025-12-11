{pkgs, ...}: {
  # Install the Rio terminal from the exposed flake input package
  # Provided via overlays as pkgs.rio
  home.packages = [pkgs.rio];
}
