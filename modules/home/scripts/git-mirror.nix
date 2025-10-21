{ pkgs, ... }:
let
  binPath = pkgs.lib.makeBinPath [
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.util-linux
  ];
  script = builtins.readFile ./git-mirror.sh;
in
pkgs.writeShellScriptBin "git-mirror" ''
  # Ensure required tools are on PATH
  export PATH=${binPath}:$PATH

  # Write the embedded script to a temp file so BASH_SOURCE[0] is set
  tmp_script=$(mktemp)
  trap 'rm -f "$tmp_script"' EXIT
  cat > "$tmp_script" <<'BASH_EOF'
${script}
BASH_EOF
  chmod +x "$tmp_script"

  # Avoid unbound variable errors in --help path where LOG_FILE isn't initialized yet
  export LOG_FILE=""

  # Execute with Bash to support bashisms
  exec ${pkgs.bash}/bin/bash "$tmp_script" "$@"
''

