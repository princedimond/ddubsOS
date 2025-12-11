{
  lib,
  pkgs,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  enableSway =
    if builtins.hasAttr "enableSway" vars
    then vars.enableSway
    else false;
  wlrVmQuirks = vars.wlrVmQuirks or false;

  swayBin = "${pkgs.sway}/bin/sway";

  swayWrapper = pkgs.writeShellScript "sway-ddub-session" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Launch Sway via user systemd so user services (Waybar, portals, etc.) come up reliably
    exec ${pkgs.systemd}/bin/systemd-run --user --scope \
      --setenv=LIBSEAT_BACKEND=logind \
      --setenv=XDG_SESSION_TYPE=wayland \
      --setenv=XDG_CURRENT_DESKTOP=sway \
      ${lib.optionalString wlrVmQuirks "--setenv=WLR_NO_HARDWARE_CURSORS=1 --setenv=WLR_RENDERER_ALLOW_SOFTWARE=1"} \
      ${swayBin}
  '';

  swaySessionPkg =
    pkgs.runCommandLocal "sway-session" {
      passthru.providedSessions = ["sway"];
    } ''
      mkdir -p $out/share/wayland-sessions $out/bin
      cp ${swayWrapper} $out/bin/sway-ddub-session
      chmod +x $out/bin/sway-ddub-session
      cat > $out/share/wayland-sessions/sway.desktop <<'EOF'
      [Desktop Entry]
      Name=Sway (Wayland)
      Comment=Sway Wayland Compositor
      Exec=${swayWrapper}
      TryExec=${swayBin}
      Type=Application
      DesktopNames=Sway
      X-Session-Type=wayland
      EOF
    '';
in {
  # Expose Wayland session entry to the display manager when Sway is enabled
  environment.pathsToLink = lib.mkIf enableSway ["/share/wayland-sessions"];

  services.displayManager.sessionPackages = lib.mkIf enableSway [swaySessionPkg];
  services.displayManager.sessionData.desktops = lib.mkIf enableSway [swaySessionPkg];

  # Ensure Sway package and integration are available
  environment.systemPackages = lib.mkIf enableSway [pkgs.sway];

  programs.sway = lib.mkIf enableSway {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      xwayland
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}
