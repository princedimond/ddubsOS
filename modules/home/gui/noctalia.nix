{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  noctaliaPath = inputs.noctalia.packages.${system}.default;
  configDir = "${noctaliaPath}/share/noctalia-shell";
in {
  # Install the Noctalia package for this user (CLI, assets, etc.).
  home.packages = [
    noctaliaPath
  ];

  # Seed the Noctalia QuickShell shell code into ~/.config/quickshell/noctalia-shell
  # once, then leave it writable so the GUI and the user can tweak it.
  home.activation.seedNoctaliaShellCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    DEST="$HOME/.config/quickshell/noctalia-shell"
    SRC="${configDir}"

    if [ ! -d "$DEST" ]; then
      mkdir -p "$HOME/.config/quickshell"
      cp -R "$SRC" "$DEST"
      chmod -R u+rwX "$DEST"
    fi
  '';
}
