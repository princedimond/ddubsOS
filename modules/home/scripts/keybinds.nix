{ pkgs }:
pkgs.writeShellScriptBin "list-keybinds" ''
  # Launch the new QuickShell keybinds menu
  exec ${pkgs.callPackage ./qs-keybinds.nix {}}/bin/qs-keybinds
''
