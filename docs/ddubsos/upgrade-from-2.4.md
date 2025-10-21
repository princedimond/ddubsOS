# Upgrade Guide: From ddubsOS v2.4 to refactor branch (host-based flake)

Date: 2025-09-06

This guide helps you upgrade from Stable v2.4 to the refactor branch that introduces:
- Host-based flake outputs (#<host>) alongside legacy profile outputs (#amd/#intel/#nvidia/...)
- Enhanced installer flags (--host/--profile/--build-host/--non-interactive)
- New zcli host management commands (add-host, del-host, rename-host, hostname set)

Prerequisites
- You are on ddubsOS Stable-v2.4 (DDUBSOS_VERSION=2.4) and your system rebuilds cleanly.
- You have a git working copy of ddubsOS under ~/ddubsos.

Step 1: Create a backup (recommended)
- Make a copy of your repo in case you want to roll back:
  cp -rp ~/ddubsos ~/ddubsos-backup-$(date +%F)

Step 2: Switch to refactor branch
- Move to the ddubos-refactor branch:
  git -C ~/ddubsos fetch --all --prune
  git -C ~/ddubsos switch ddubos-refactor

Important: First rebuild must be nixos-rebuild (not zcli)
- On Stable v2.4 the installed zcli does not have refactor-aware logic. Do one rebuild with your existing legacy profile target to install the updated zcli. Examples:
  sudo nixos-rebuild switch --flake ~/ddubsos#vm
  sudo nixos-rebuild boot   --flake ~/ddubsos#vm
- Note: During this initial upgrade, hostname targets (.#<host>) will NOT work for switch/boot; use the legacy profile target. After this first rebuild, you may use zcli and host-based targets normally.

Step 3: Review changes
- Host-based flake outputs are added for each directory in hosts/.
- Legacy profile outputs remain (amd, intel, nvidia, nvidia-laptop, vm) to preserve current installer and workflows.
- Installer gains flags and non-interactive mode; zcli gains host management commands.
- Home Manager can now share the global package set via a toggle.

Step 4: Choose your build target
- Option A: Continue using legacy profile targets (no changes needed):
  sudo nixos-rebuild switch --flake .#amd   # or intel/nvidia/...
- Option B: Switch to host-based target (preferred going forward):
  sudo nixos-rebuild switch --flake .#<your-host>

Step 5: Update/install with the refined installer (optional)
- New flags:
  --host NAME          # preselect hostname
  --profile NAME       # one of amd|intel|nvidia|nvidia-laptop|vm
  --build-host         # build by host target (instead of profile)
  --non-interactive    # accept defaults; no prompts

- Examples:
  ./install-ddubsos.sh --host ixas --profile amd --build-host
  ./install-ddubsos.sh --non-interactive --build-host

Step 6: zcli host management (optional)
- Scaffold a new host:
  zcli add-host my-laptop [amd|intel|nvidia|nvidia-laptop|vm]
  # Use zcli update-host my-laptop <profile> to set flake host/profile

- Delete a host:
  zcli del-host my-laptop

- Rename a host and update flake host if it was pointing to the old name:
  zcli rename-host old-name new-name

- Set flake host (does not move folders):
  zcli hostname set <new-host>


Step 8: Rebuild and validate
- Check formatting and basic sanity:
  nix flake check --print-build-logs
- Rebuild (choose one):
  sudo nixos-rebuild switch --flake .#<host>
  sudo nixos-rebuild switch --flake .#<profile>

Example: upgrade a VM host (ddubsos-vm) to host-based builds

This example shows a typical migration on a VM currently using legacy profile targets.

1) Switch to the refactor branch
- git -C ~/ddubsos switch ddubos-refactor

2) Ensure a host directory exists
- If hosts/ddubsos-vm already exists, you can use it.
- Otherwise scaffold it:
  - zcli add-host ddubsos-vm vm
  - Edit hosts/ddubsos-vm/variables.nix (browser, terminal, stylixImage, etc.)

3) Point flake host/profile to ddubsos-vm
- zcli update-host ddubsos-vm vm
  - This sets host = "ddubsos-vm" and profile = "vm" in flake.nix

4) Rebuild using the host target (new preferred path)
- sudo nixos-rebuild switch --flake .#ddubsos-vm

Note: You can still build with the legacy profile target at any time:
- sudo nixos-rebuild switch --flake .#vm

Troubleshooting
- Duplicate module definitions (e.g., sysctl swappiness) usually indicate hosts/<host> was imported twice. The refactor avoids double-import; ensure you don’t manually import both hosts/<host> and profiles/<profile> in the same stack.
- If Alejandra formatting fails in flake checks, run: nix fmt

Roll back to v2.4
- If needed, switch to the stable branch:
  git -C ~/ddubsos switch Stable-v2.4
  sudo nixos-rebuild switch --flake .#<profile>

Notes
- Keep system.stateVersion and home.stateVersion pinned.
- For new hosts, use zcli add-host and zcli update-host to keep flake host/profile aligned.

