{
  pkgs,
  lib,
  ...
}: let
  # Guard against package availability differences across nixpkgs revisions
  incusPkg =
    if builtins.hasAttr "incus" pkgs
    then pkgs.incus
    else null;
  # UI package name in nixpkgs is typically "incus-ui-canonical"
  incusUiPkg =
    if builtins.hasAttr "incus-ui-canonical" pkgs
    then pkgs.incus-ui-canonical
    else if builtins.hasAttr "incus-ui" pkgs
    then pkgs.incus-ui
    else null;

  # Convenience wrapper to ensure `incus webui` can find static assets when the UI is installed
  incusWebuiWrapper =
    if incusPkg != null && incusUiPkg != null
    then
      pkgs.writeShellScriptBin "incus-webui" ''
        #!/usr/bin/env bash
        export INCUS_UI="${incusUiPkg}/share/incus/ui"
        exec -a incus "${incusPkg}/bin/incus" webui "$@"
      ''
    else null;

  extras = lib.optional (incusWebuiWrapper != null) incusWebuiWrapper;

  packages =
    (lib.optionals (incusPkg != null) [incusPkg])
    ++ (lib.optionals (incusUiPkg != null) [incusUiPkg])
    ++ extras;
in {
  # Install Incus CLI/daemon and the Incus Web UI if available in this nixpkgs
  home.packages = packages;
}
