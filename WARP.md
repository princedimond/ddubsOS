# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project type: NixOS flake with Home Manager (multi-host, multi-profile). Prefer host-based builds; legacy GPU “profile” builds remain available.

Common commands

- Build/test current config (dry-run build/activation)
  ```bash path=null start=null
  nix flake check                    # runs flake checks (incl. alejandra --check)
  nh os test                         # build + test activation (no switch)
  ```
- Switch to new configuration (activate now)
  ```bash path=null start=null
  zcli rebuild                       # recommended wrapper (safety checks + staging prompt)
  nh os switch                       # raw nh switch
  sudo nixos-rebuild switch --flake .#<host>
  # Legacy profile-based:
  sudo nixos-rebuild switch --flake .#<profile>   # amd | intel | nvidia | nvidia-laptop | vm
  ```
- Safer major change (activate on reboot)
  ```bash path=null start=null
  zcli rebuild-boot
  ```
- Update inputs and rebuild
  ```bash path=null start=null
  zcli update                        # flake update + switch (with staging prompt)
  # or via justfile targets
  just get-updates                   # nix flake update (+ nvfetcher)
  just update                        # updates then commits
  ```
- Formatting and linting (Nix)
  ```bash path=null start=null
  nix fmt                            # uses flake formatter (alejandra)
  alejandra --check .                # explicit format check
  nix flake check                    # includes formatting check via checks
  ```
- Garbage collect and optimise
  ```bash path=null start=null
  just gc                            # keep 5 generations
  just optimise                      # deduplicate store via hard links
  ```
- Host management essentials (zcli)
  ```bash path=null start=null
  zcli add-host <hostname> [profile]         # scaffold from hosts/default
  zcli update-host <hostname> [profile]      # rewrite host/profile in flake.nix
  zcli list-gens | zcli trim | zcli diag     # generation utils and diagnostics
  ```
- Suckless components (local build only; Nix manages install normally)
  ```bash path=null start=null
  make -C modules/home/dwm-setup/suckless/dwm
  make -C modules/home/dwm-setup/suckless/st
  make -C modules/home/dwm-setup/suckless/slstatus
  ```

Notes on tests

- There are no conventional unit tests in this repo. Validation is via flake checks and dry-run system builds:
  - nix flake check
  - nh os test

High-level architecture

- Entry point and outputs
  - /home/dwilliams/Projects/ddubs/ddubsos/flake.nix defines inputs (nixpkgs, home-manager, stylix, hyprpanel source, ags, devenv, etc.) and two build modes:
    - Legacy profile-based outputs (amd, intel, nvidia, nvidia-laptop, vm) via mkNixosConfig
    - Preferred host-based outputs generated from hosts/<host> via mkHostConfig
  - Global formatter and checks are flake outputs (alejandra), so nix fmt and nix flake check integrate with the repo.
- Host- and profile-model
  - hosts/<host>/{hardware.nix, default.nix, host-packages.nix, variables.nix}
  - flake carries a let-bound profile passed into modules via specialArgs.profile; installer and zcli update host/profile values in place
- Modules layout (big picture)
  - modules/core: system-level features (security, services, printing, fonts, flatpak, nh, overlays, steam, stylix, user/session env, xserver/DM, virtualization, networking)
  - modules/home: Home Manager modules for DEs, terminals, shells, editors, GUI apps, scripts, suckless setup, hyprland, waybar, etc.
  - profiles/: GPU/role-specific NixOS profiles
  - overlays: implemented in modules/core/overlays.nix to expose selected flake inputs (e.g., hyprpanel, ags, wfetch) as pkgs.<name>; modules should reference pkgs.<name>, not inputs.*
- Home Manager composition and toggles
  - Primary entry: /home/dwilliams/Projects/ddubs/ddubsos/modules/home/default.nix
    - Always imports a base set (terminals, shells, CLI tools, hyprland stack, etc.)
    - Conditionally imports modules based on hosts/<host>/variables.nix toggles: desktop environments (gnome/bspwm/dwm/wayfire/cosmic), editors (evil-helix, vscode), extra terminals (alacritty, tmux, ptyxis), dev-env, opencode, etc.
    - File-backed choices: waybarChoice, starshipChoice reference specific module files
- Session startup (Hyprland)
  - Startup flow is centralized in /home/dwilliams/Projects/ddubs/ddubsos/modules/home/hyprland/exec-once.nix with panel-specific branching:
    - hyprpanel (default) vs waybar; wallpaper fallbacks, notifier handling, pypr dropdown terminal, copyq, etc.
- Packages and theming
  - System-wide essentials: modules/core/req-packages.nix; optional globals: modules/core/global-packages.nix; per-host: hosts/<host>/host-packages.nix
  - Stylix + catppuccin provide theming; stylixImage used for wallpaper fallback

Warp-specific notes

- Warp terminal integration
  - A bleeding-edge Warp module exists under modules/apps/warp-terminal-current.*
  - When enabled (programs.warp-terminal-current.enable = true), both warp-terminal (stable) and warp-bld (bleeding-edge) are installed; a desktop entry and icon are registered; Wayland can be toggled via WARP_ENABLE_WAYLAND
  - Check version of the packaged current build:
    ```bash path=null start=null
    nix eval .#packages.x86_64-linux.warp-terminal-current.version
    ```

Important references from docs

- Host-first builds and commands (from README and docs/project-guide.md)
  - Preferred: sudo nixos-rebuild switch --flake .#<host>
  - Legacy: sudo nixos-rebuild switch --flake .#<profile>
  - Installer flags (install-ddubsos.sh): --host <name> --profile <amd|intel|nvidia|nvidia-laptop|vm> --build-host --non-interactive
- zcli (docs/project-guide.md) is the recommended operator interface:
  - zcli rebuild | rebuild-boot | update | stage [--all]
  - zcli add-host, del-host, update-host
  - Safety features include staging prompts and backup cleanup

Conventions and environment

- Repo is designed for NixOS 23.11+ (25.05+ recommended). The repository path is commonly expected at ~/ddubsos for scripts and docs, though the flake works from any directory.
- Formatting: use nix fmt (alejandra); CI-like checks are embedded in flake checks.
- Prefer zcli for day-to-day builds and updates; use nh/nixos-rebuild when needed.
