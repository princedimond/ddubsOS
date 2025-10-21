{ lib, pkgs, host, ... }:
let
  vars = import ../../hosts/${host}/variables.nix;
  enableNiri = if builtins.hasAttr "enableNiri" vars then vars.enableNiri else (if builtins.hasAttr "niriEnable" vars then vars.niriEnable else false);

  niriSessionPkg = pkgs.runCommandLocal "niri-session" {
    passthru.providedSessions = [ "niri" ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/niri.desktop <<'EOF'
[Desktop Entry]
Name=Niri (Wayland)
Comment=Niri Wayland Compositor
Exec=${pkgs.niri}/bin/niri-session
TryExec=${pkgs.niri}/bin/niri-session
Type=Application
DesktopNames=Niri
X-Session-Type=wayland
EOF
  '';

in
{
  # Create session entries for both SDDM backends and ensure they are discoverable
  environment.pathsToLink = lib.mkIf enableNiri [ "/share/wayland-sessions" ];

  services.displayManager.sessionPackages = lib.mkIf enableNiri [ niriSessionPkg ];
  services.displayManager.sessionData.desktops = lib.mkIf enableNiri [ niriSessionPkg ];

  # Make sure Niri is installed when the session is enabled
  environment.systemPackages = lib.mkIf enableNiri [ pkgs.niri ];
}

