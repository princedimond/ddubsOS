{ config, ... }:
let
  repoToprc = "${config.home.homeDirectory}/ddubsos/modules/home/cli/procps-toprc";
  homeToprc = "${config.home.homeDirectory}/.config/procps/toprc";
in {
  # RW-friendly, seed-once behavior:
  # - If the live file exists and the repo copy does not, copy live -> repo (first capture)
  # - If the repo copy exists and the live file does not, copy repo -> live (first seed)
  # - If both exist, do nothing (keep ~/.config/procps/toprc editable by top)
  home.activation = {
    seedProcpsToprcRepo = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "${homeToprc}" ] && [ ! -f "${repoToprc}" ]; then
        echo "[toprc] Seeding repo from ${homeToprc} -> ${repoToprc}"
        mkdir -p "$(dirname "${repoToprc}")"
        cp -f "${homeToprc}" "${repoToprc}"
      fi
    '';

    seedProcpsToprcHome = config.lib.dag.entryAfter [ "seedProcpsToprcRepo" ] ''
      if [ ! -f "${homeToprc}" ] && [ -f "${repoToprc}" ]; then
        echo "[toprc] Installing to home from repo ${repoToprc} -> ${homeToprc}"
        mkdir -p "$(dirname "${homeToprc}")"
        install -m 0644 "${repoToprc}" "${homeToprc}"
      fi
    '';
  };
}
