{
  lib,
  host,
  pkgs,
  inputs,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  enableMangowc = vars.enableMangowc or false;

  mangoWrapper = pkgs.writeShellScript "mango-ddub-session" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_RENDERER_ALLOW_SOFTWARE=1
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=mango
    exec mango
  '';

  mangoSessionPkg =
    pkgs.runCommandLocal "mango-session" {
      passthru.providedSessions = ["mango-ddub"];
    } ''
      mkdir -p $out/share/wayland-sessions $out/bin
      cp ${mangoWrapper} $out/bin/mango-ddub-session
      chmod +x $out/bin/mango-ddub-session
      cat > $out/share/wayland-sessions/mango-ddub.desktop <<'EOF'
      [Desktop Entry]
      Name=Mango (VM cursor fix)
      Comment=Mango Wayland Compositor with VM cursor workaround
      Exec=${mangoWrapper}
      TryExec=mango
      Type=Application
      DesktopNames=Mango
      X-Session-Type=wayland
      EOF
    '';
in {
  # Enable upstream MangoWC system module when toggled per-host.
  programs.mango.enable = lib.mkIf enableMangowc true;

  # Provide a custom Mango session desktop that exports env fixes (cursor) before launching.
  environment.pathsToLink = lib.mkIf enableMangowc ["/share/wayland-sessions"];
  services.displayManager.sessionPackages = lib.mkIf enableMangowc [mangoSessionPkg];
  services.displayManager.sessionData.desktops = lib.mkIf enableMangowc [mangoSessionPkg];
}
