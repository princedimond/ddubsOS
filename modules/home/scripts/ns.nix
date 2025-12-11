{pkgs}: let
  nixSearchTv = pkgs."nix-search-tv";
  upstream = builtins.readFile "${nixSearchTv.src}/nixpkgs.sh";
  runtimeBinPath = pkgs.lib.makeBinPath [pkgs.fzf nixSearchTv];
in
  pkgs.writeShellScriptBin "ns" (
    ''
      #!/usr/bin/env bash
      set -euo pipefail
      # Ensure tools are on PATH at runtime
      export PATH='${runtimeBinPath}':"$PATH"
      # shellcheck disable=SC2016
    ''
    + upstream
  )
