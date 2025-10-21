# Zed Editor on NixOS: Overlay + Home Manager (RW config without symlinks)

Audience: Linux users who are new to NixOS and want a practical way to run Zed with writable config under Home Manager, plus a scoped overlay to fix upstream hash issues.

---

## Problem statement (September 2025)

In early September 2025, building zed-editor from nixpkgs began failing with a fixed-output derivation hash mismatch. Nix requires the exact content hash for fixed-output fetchers; when the upstream GitHub tag tarball changes, the hash changes and the build fails until updated. The error looked like this:

- specified: sha256-4cP6cohUZdhvr6mvIOozhg1ahEZEypCCjvAz0fjAtec=
- got:      sha256-Q7Ord+GJJcOCH/S3qNwAbzILqQiIC94qb8V+JkzQqaQ=

This occurred while fetching zed-industries/zed at tag v0.202.5. The workaround here pins fetchFromGitHub to that tag and sets sha256 to the “got” value—scoped locally so it only applies when Zed is enabled. Once nixpkgs updates to the new upstream hash, the overlay can be removed.

---

## Overview

This document explains a working approach to:
- Install Zed via Home Manager
- Keep Zed’s config writable (no Home Manager symlinks), so the app can change settings while you test
- Sync your live settings back into the repo on rebuild, then install them again
- Scope an overlay to Zed only (and only when enabled) to fix a fixed-output hash mismatch caused by upstream tarball changes

The solution lives in:
- Module: modules/home/editors/zed-editor.nix
- Managed settings (copied into ~/.config/zed): modules/home/editors/zed-config/
- Host switch: enableZed in hosts/<host>/variables.nix and imported in modules/home/default.nix

---

## Why the overlay?

Zed’s source archive (GitHub tag tarball) changed upstream, which caused a fixed-output derivation hash mismatch during build. Nix requires exact hashes for fixed-output fetches (e.g., fetchFromGitHub), so the build fails until the expected hash matches the actual content.

We fix this by providing a very narrow overlay that only affects zed-editor and only when this Home Manager module is imported. The overlay:
- Pins fetchFromGitHub to the known tag (v0.202.5)
- Sets sha256 to the “got” value Nix reported during the failure
- Scopes the change inside the HM module (not globally), so other hosts remain unaffected

Code (overlay block):
```nix path=/home/dwilliams/ddubsos/modules/home/editors/zed-editor.nix start=11
  nixpkgs.overlays = [
    (final: prev: {
      zed-editor = prev.zed-editor.overrideAttrs (old: {
        # Force src to a concrete fetchFromGitHub with the correct hash.
        # This bypasses any internal pinned fetch used by the package.
        src = prev.fetchFromGitHub {
          owner = "zed-industries";
          repo = "zed";
          rev = "v0.202.5"; # keep in sync with the package version
          sha256 = "sha256-Q7Ord+GJJcOCH/S3qNwAbzILqQiIC94qb8V+JkzQqaQ=";
          fetchSubmodules = true;
        };
      });
    })
  ];
```

Notes:
- If/when nixpkgs updates Zed, you can remove or update this overlay.
- Keeping the overlay here (in the HM module) means it’s applied only if enableZed is true.

---

## Enabling Zed per host

You enable Zed per host with a boolean flag in hosts/<host>/variables.nix (enableZed). modules/home/default.nix imports the Zed module only if that flag is true.

Snippet (conditional import):
```nix path=/home/dwilliams/ddubsos/modules/home/default.nix start=69
  ++ (if gnomeEnable then [ ./gui/gnome.nix ] else [ ])
  ++ (if enableZed then [ ./editors/zed-editor.nix ] else [ ])
  ++ (if bspwmEnable then [ ./gui/bspwm.nix ] else [ ])
```

This makes it easy to roll Zed out to one machine (e.g., ixas) while keeping others untouched.

---

## Home Manager: copy, don’t symlink (keep files writable)

Zed writes to its config while you work (welcome wizard, UI changes, etc.). If Home Manager symlinks these files, the app may still write, but you often want the plain files on disk, writable, and not read-only store links. So we:
- Maintain a repo copy of your Zed config under modules/home/editors/zed-config/
- During activation, copy the repo contents into ~/.config/zed (no symlinks), ensuring files remain RW for Zed

This avoids surprises and keeps UX simple for app-driven edits.

---

## Backup and Sync: order of operations

To prevent data loss while still giving you reproducible config, activation runs three steps in order:

1) Sync live settings back into the repo
- Copy ~/.config/zed/. into modules/home/editors/zed-config/
- This captures any changes you made in Zed since the last rebuild

2) Backup the live directory
- Move ~/.config/zed to ~/.config/zed.bak-YYYYmmdd-HHMMSS
- A safety net if you want to recover the last live state

3) Install from the repo
- Copy modules/home/editors/zed-config/. into ~/.config/zed
- Ensure chmod -R u+w so files are writable by you/Zed
- Clean up obsolete nested directories if we ever had a legacy layout

Annotated code (activation DAG):
```nix path=/home/dwilliams/ddubsos/modules/home/editors/zed-editor.nix start=33
  home.activation = {
    # First, sync any live changes back into the repo-managed directory
    syncZedBack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "${zedConfigDir}" ]; then
        mkdir -p "${repoZedConfig}"
        echo "Syncing live Zed config from ${zedConfigDir} back to ${repoZedConfig}"
        cp -r --no-preserve=all "${zedConfigDir}/." "${repoZedConfig}/" 2>/dev/null || true
      fi
    '';

    # Then, back up the live config
    backupZed = lib.hm.dag.entryAfter [ "syncZedBack" ] ''
      if [ -d "${zedConfigDir}" ]; then
        echo "Backing up existing Zed config from ${zedConfigDir} to ${zedConfigDir}.bak-${timestamp}"
        mv "${zedConfigDir}" "${zedConfigDir}.bak-${timestamp}"
      fi
    '';

    installZed = lib.hm.dag.entryAfter [ "backupZed" ] ''
      mkdir -p "${zedConfigDir}"
      if [ -d "${repoZedConfig}" ]; then
        echo "Copying managed Zed config from ${repoZedConfig} to ${zedConfigDir} (no symlinks)"
        # Use "." to include dotfiles and copy directory contents
        cp -r --no-preserve=all "${repoZedConfig}/." "${zedConfigDir}/" 2>/dev/null || true
        # Clean up any legacy nested 'zed' directory if present and not managed
        if [ ! -d "${repoZedConfig}/zed" ] && [ -d "${zedConfigDir}/zed" ]; then
          rm -rf "${zedConfigDir}/zed"
        fi
        chmod -R u+w "${zedConfigDir}"
      else
        echo "Warning: ${repoZedConfig} not found. Skipping Zed config copy."
      fi
    '';
  };
```

Implementation notes:
- We use cp -r --no-preserve=all instead of rsync to avoid requiring rsync in the HM unit environment.
- Using "${dir}/." ensures we copy dotfiles.
- chmod -R u+w guarantees Zed can write its files after install (important for RW behavior).

---

## Daily workflow

- Configure Zed normally. It updates ~/.config/zed in real time.
- When you zcli rebuild:
  - Your live edits are harvested back into modules/home/editors/zed-config
  - The repo copy is (re)installed into ~/.config/zed
- Git commit/push modules/home/editors/zed-config to preserve your curated setup

This gives you the benefits of Nix (reproducible install) and the ergonomics of RW app config while iterating.

---

## Trade-offs and alternatives

- Symlinks via home.file: Simpler, but you lose the “app manages files freely” UX and can run into unwritable store paths if not handled carefully.
- Generate settings with Nix: Very reproducible, but not great for frequent in-app changes; you’d edit Nix every time.
- Copy-once, never sync back: Safer, but you’d have to manually bring changes into the repo, which is easy to forget.

This solution aims for a middle ground that fits GUI/editor UX.

---

## Changing versions (overlay maintenance)

- If Zed updates upstream and you hit another hash mismatch, update rev and sha256 inside the overlay block to the new tag and “got” hash.
- Once nixpkgs catches up, you can remove the overlay entirely.

---

## Troubleshooting

- HM unit fails with command not found: rsync
  - Fixed by using cp instead of rsync in activation (already applied here)
- Welcome wizard doesn’t run
  - That happens if settings.json/config.json already exist. Remove them from ~/.config/zed and/or keep the repo empty to let Zed bootstrap.
- Live changes aren’t showing up in the repo
  - Ensure you actually ran a rebuild (zcli rebuild). The sync happens on activation.

---

## Files and paths

- Repo-managed config (copied into place):
  - modules/home/editors/zed-config/
- Live config:
  - ~/.config/zed/
- Backups (on each activation if live dir existed):
  - ~/.config/zed.bak-YYYYmmdd-HHMMSS

---

## Summary

- Overlay solves a transient upstream hash mismatch for Zed, scoped to this HM module and host flag.
- Home Manager activation script syncs live edits back into the repo, backs up, then installs repo content as plain files so Zed can keep writing.
- The result: You can iterate inside the app and still preserve your configuration under version control.

