{ pkgs, ... }:
let
  binPath = pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.procps
    pkgs.psmisc
    pkgs.lsof
    pkgs.gnugrep
    pkgs.gawk
    pkgs.findutils
    pkgs.util-linux
    pkgs.flatpak
    pkgs.bash
  ];
  script = builtins.readFile ./reset.warp;
 in
pkgs.writeShellScriptBin "reset.warp" ''
  set -euo pipefail
  # Ensure required tools are on PATH
  export PATH=${binPath}:$PATH

  # Write the embedded script to a temp file and exec with bash
  tmp_script=$(mktemp)
  trap 'rm -f "$tmp_script"' EXIT
  cat > "$tmp_script" <<'BASH_EOF'
${script}
BASH_EOF
  chmod +x "$tmp_script"
  exec ${pkgs.bash}/bin/bash "$tmp_script" "$@"
''

