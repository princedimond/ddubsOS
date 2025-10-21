# Hyprpanel on NixOS: Home Manager RW config without symlinks (review + improvements)

Audience: Linux users new to NixOS who want an ergonomic, writable config workflow for Hyprpanel under Home Manager—similar to the Zed approach.

---

## Current approach in this repo

The module modules/home/hyprpanel.nix currently copies the repo’s Hyprpanel files into ~/.config/hyprpanel and makes them writable:

```nix path=/home/dwilliams/ddubsos/modules/home/hyprpanel.nix start=1
{ config, ... }: {
  home.activation.setupHyprpanel = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/hyprpanel"
    cp -r --no-preserve=all ${config.home.homeDirectory}/ddubsos/modules/home/hyprpanel/* "$HOME/.config/hyprpanel/"
    chmod -R u+w "$HOME/.config/hyprpanel"
  '';

  home.file = {
    ".local/bin/" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
```

Pros:
- Simple: copies from repo to ~/.config/hyprpanel and ensures files are RW
- Uses Home Manager activation to install the files each rebuild

Cons / small gaps:
- No sync-back of live edits: changes made in ~/.config/hyprpanel won’t automatically land back in the repo
- No backup before overwriting: a failed copy or user edits could be overwritten without a safety net
- cp with a trailing `*` won’t include dotfiles (e.g., hidden files), which can be important for some tools

---

## Suggested improvements

1) Add a sync-back step before install
- Copy ~/.config/hyprpanel/. back into modules/home/hyprpanel (repo) so live edits are captured before we overwrite the live dir. This mirrors the Zed solution and supports a pleasant app-first workflow.

2) Add a backup step
- Before copying the repo contents into place, back up ~/.config/hyprpanel to ~/.config/hyprpanel.bak-YYYYmmdd-HHMMSS. This makes it easy to recover if you ever want to roll back a local tweak.

3) Copy dotfiles and ensure RW
- Use the `"${dir}/."` pattern with cp so hidden files are copied.
- Run `chmod -R u+w` so Hyprpanel (or you) can keep editing the files post-install.

4) Keep it rsync-free
- Using `cp -r --no-preserve=all` avoids introducing rsync as a dependency for the Home Manager unit.

---

## Proposed implementation

Below is a drop-in replacement for the activation logic. It mirrors the Zed module’s pattern: sync back, backup, then install.

```nix path=null start=null
{ config, lib, ... }:
let
  repoHyprCfg = "${config.home.homeDirectory}/ddubsos/modules/home/hyprpanel";
  hyprCfgDir  = "${config.home.homeDirectory}/.config/hyprpanel";
  timestamp   = "$(date +%Y%m%d-%H%M%S)";
in
{
  home.activation = {
    # 1) Sync live edits back into the repo-managed directory
    syncHyprpanelBack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "${hyprCfgDir}" ]; then
        echo "Syncing live hyprpanel config from ${hyprCfgDir} back to ${repoHyprCfg}"
        mkdir -p "${repoHyprCfg}"
        cp -r --no-preserve=all "${hyprCfgDir}/." "${repoHyprCfg}/" 2>/dev/null || true
      fi
    '';

    # 2) Backup the current live directory (if present)
    backupHyprpanel = lib.hm.dag.entryAfter [ "syncHyprpanelBack" ] ''
      if [ -d "${hyprCfgDir}" ]; then
        echo "Backing up existing hyprpanel config from ${hyprCfgDir} to ${hyprCfgDir}.bak-${timestamp}"
        mv "${hyprCfgDir}" "${hyprCfgDir}.bak-${timestamp}"
      fi
    '';

    # 3) Install from the repo into ~/.config/hyprpanel (no symlinks; keep files RW)
    installHyprpanel = lib.hm.dag.entryAfter [ "backupHyprpanel" ] ''
      mkdir -p "${hyprCfgDir}"
      if [ -d "${repoHyprCfg}" ]; then
        echo "Copying managed hyprpanel config from ${repoHyprCfg} to ${hyprCfgDir} (no symlinks)"
        cp -r --no-preserve=all "${repoHyprCfg}/." "${hyprCfgDir}/" 2>/dev/null || true
        chmod -R u+w "${hyprCfgDir}"
      else
        echo "Warning: ${repoHyprCfg} not found. Skipping hyprpanel config copy."
      fi
    '';
  };

  # Keep the existing .local/bin population via HM (symlinks are fine for scripts)
  home.file.".local/bin/" = {
    source = ./scripts;
    recursive = true;
  };
}
```

Why this works well:
- You can tweak files in ~/.config/hyprpanel during the day without thinking about Nix.
- A rebuild harvests those changes into the repo, gives you a backup, and then installs the repo copy back into place.
- You can commit/push modules/home/hyprpanel to preserve what you like.

---

## Tips and optional guardrails

- Consider adding a tiny README to modules/home/hyprpanel explaining the copy-back workflow for contributors.
- If you prefer to keep a rolling archive, you can tar the repo copy (or the live directory) before each sync/backup.
- If some files should never be overwritten by the repo (e.g., per-host secrets), add exclusion rules (e.g., skip known filenames in the cp commands) and surface a warning if they exist.

---

## Summary

- The current module already delivers writable config by copying from the repo into ~/.config/hyprpanel.
- The suggested changes add bidirectional sync and backups, matching the pattern used for the Zed editor.
- This pattern sidesteps the “must rebuild for every small edit” feel and gives a pragmatic, Nix-friendly UX for tinkering—perfect for personal setups where strict reproducibility isn’t mandatory.

