{
  lib,
  pkgs,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  oxwmEnable = vars.oxwmEnable or false;

  oxwmSessionPkg =
    pkgs.runCommandLocal "oxwm-session" {
      passthru.providedSessions = ["oxwm"];
    } ''
      mkdir -p $out/share/xsessions
      cat > $out/share/xsessions/oxwm.desktop <<'EOF'
      [Desktop Entry]
      Name=OXWM
      Comment=OXWM X11 Tiling Window Manager
      Exec=${pkgs.oxwm}/bin/oxwm
      TryExec=${pkgs.oxwm}/bin/oxwm
      Type=XSession
      EOF
    '';
in {
  # Register oxwm session for display managers
  services.displayManager.sessionPackages = lib.mkIf oxwmEnable [oxwmSessionPkg];

  # Ensure oxwm and xwayland are available
  environment.systemPackages = lib.mkIf oxwmEnable [pkgs.oxwm oxwmSessionPkg];

  # Enable xwayland for X11 session support under Wayland
  programs.xwayland.enable = true;
}
