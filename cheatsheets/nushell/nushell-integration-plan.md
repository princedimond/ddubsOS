English | [Español](./nushell-integration-plan.es.md)

# Nushell Integration Plan (for ddubsOS)
Audience: future AI assistant and maintainers. This document captures the exact
repository context, file references, and concrete steps/code needed to integrate
Nushell (nu) as a first-class, selectable shell alongside zsh/bash/fish.

## TODO Checklist

- [ ] Add `shellChoice = "zsh";` to `hosts/default/variables.nix`
- [ ] Update `modules/home/default.nix` with conditional shell imports based on `shellChoice`
- [ ] Create `modules/home/shells/nushell.nix` with:
  - [ ] Nushell program configuration
  - [ ] eza aliases (ls, ll, la, tree, d, dir)
  - [ ] zoxide functions (zi interactive, z direct)
  - [ ] Starship prompt integration
- [ ] Update fastfetch wrappers (`modules/home/scripts/ff*.nix`) to detect Nushell
- [ ] Review existing shell configs for parity:
  - [ ] `modules/home/zsh/zshrc-personal`
  - [ ] `modules/home/zsh/default.nix`
  - [ ] `modules/home/shells/eza.nix`
- [ ] Test on a host by setting `shellChoice = "nushell"`
- [ ] Validate eza aliases, zoxide functions, and Starship prompt work in Nushell
- [ ] Confirm fastfetch shows "nu" as shell when run from Nushell

Overview

- Goal: Add Nushell as an optional shell, integrated similarly to existing
  shells, controlled per-host via a host variable. Preserve existing eza and
  zoxide conventions.
- Do NOT change behavior now; this is a ready-to-execute plan.

Relevant repository references (as of writing)

- Host variables pattern:
  - hosts/default/variables.nix
  - hosts/<host>/variables.nix (e.g., hosts/ixas/variables.nix)
- Home import orchestration:
  - modules/home/default.nix
- Current shell modules:
  - modules/home/zsh/default.nix
  - modules/home/zsh/zshrc-personal.nix
  - modules/home/shells/bash.nix
  - modules/home/shells/bashrc-personal.nix
  - modules/home/shells/fish.nix
  - modules/home/shells/zoxide.nix
  - modules/home/shells/eza.nix
- Shared CLI bits:
  - modules/home/cli/fzf.nix (fzf present)
  - modules/home/cli/default.nix (imports fastfetch, fzf, git, etc.)
- Fastfetch wrappers (already shell-aware):
  - modules/home/scripts/ff.nix
  - modules/home/scripts/ff1.nix
  - modules/home/scripts/ff2.nix

High-level design

1. Add a host variable shellChoice = "zsh" | "bash" | "fish" | "nushell".
2. Update modules/home/default.nix to conditionally import the correct shell
   module based on shellChoice.
3. Create a new modules/home/shells/nushell.nix that:
   - Enables Nushell via Home Manager.
   - Adds Nushell-native aliases mirroring eza aliases used in other shells.
   - Adds Nushell functions for zoxide usability (zi interactive, z basic),
     mirroring your zoxide UX.
   - Optional: integrate Starship prompt in Nushell if desired.
4. Optionally extend ff wrappers’ shell detection to explicitly handle Nushell
   (nu) so Fastfetch shows nu when invoked from Nushell.

Step 1: Add host variable

- In hosts/default/variables.nix, add a new variable with a safe default (do not
  change other hosts unless desired):

```
shellChoice = "zsh";  # options: "zsh" | "bash" | "fish" | "nushell"
```

- Hosts can override this in hosts/<host>/variables.nix, e.g.:

```
shellChoice = "nushell";
```

Step 2: Wire shellChoice into modules/home/default.nix

- Current behavior imports all shells. Change to conditional imports driven by
  shellChoice.
- Example replacement for the “# Shells” block (adjust paths as needed):

```
# Before: unconditionally importing shells
#   ./shells/bash.nix
#   ./shells/bashrc-personal.nix
#   ./shells/eza.nix
#   ./shells/fish.nix
#   ./shells/zoxide.nix
#   ./zsh/default.nix
#   ./zsh/zshrc-personal.nix

# After: conditional imports
let
  inherit (import ../../hosts/${host}/variables.nix)
    shellChoice
    # ... existing inherits
  ;

  shellImports =
    if shellChoice == "zsh" then [
      ./zsh/default.nix
      ./zsh/zshrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else if shellChoice == "bash" then [
      ./shells/bash.nix
      ./shells/bashrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else if shellChoice == "fish" then [
      ./shells/fish.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else if shellChoice == "nushell" then [
      ./shells/nushell.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else [
      # Fallback (zsh) if invalid value provided
      ./zsh/default.nix
      ./zsh/zshrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ];
in {
  imports = [
    # ... other imports
  ] ++ shellImports
    # ... remaining conditional imports already present in this file
  ;
}
```

Notes:

- We keep eza.nix and zoxide.nix in the per-shell list to ensure they’re loaded
  for every chosen shell. This also keeps the global alias behavior consistent
  across shells that respect home.shellAliases (bash/zsh/fish). Nushell needs
  its own aliases (see Step 3).

Step 3: Create modules/home/shells/nushell.nix

- New file: modules/home/shells/nushell.nix
- Provide Nushell config with eza aliases and zoxide helpers. Home Manager
  supports programs.nushell.

```
{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    # You can add settings like:  configFile.text or envFile.text if needed.
    # Use extraConfig for interactive helpers and aliases.
    extraConfig = ''
      # =========================
      # eza aliases (Nushell)
      # =========================
      alias ls = eza
      alias ll = eza -a --no-user --long
      alias la = eza -lah
      alias tree = eza --tree
      alias d = eza -a --grid
      alias dir = eza -a --grid

      # =========================
      # zoxide helpers (Nushell)
      # =========================
      # Interactive selector (like your "zi"), then cd into selection.
      def --env zi [] {
        let dest = ( ^${pkgs.zoxide}/bin/zoxide query -i )
        if ($dest | is-empty) == false { cd $dest }
      }

      # Basic "z" to jump directly to best match
      def --env z [ ...rest ] {
        let dest = ( ^${pkgs.zoxide}/bin/zoxide query -- $rest | lines | first )
        if ($dest | is-empty) == false { cd $dest }
      }

      # =========================
      # Optional: Starship prompt for Nushell
      # =========================
      # If you want the same prompt everywhere, Home Manager can manage
      # Starship's config. For Nushell specifically, uncomment the lines below
      # to initialize Starship in Nu:
      # let-env STARSHIP_SHELL = "nushell"
      # use std "path add"
      # let-env PROMPT_COMMAND = ( ^${pkgs.starship}/bin/starship init nu | from nuon )
      # let-env PROMPT_COMMAND_RIGHT = ""
    '';
  };

  # Optional: centralized Starship configuration (shared across shells)
  programs.starship = {
    enable = true;
    # settings can live in pkgs.writeText or via home.file if you want custom prompt
    # format shared across shells. Keep existing repo conventions.
  };
}
```

Notes:

- Nushell does not consume home.shellAliases, so aliases must be defined here in
  extraConfig.
- The zoxide functions use zoxide directly; this mirrors your desired "zi" UX
  without relying on zoxide’s auto-init. If you prefer zoxide’s official Nu init
  snippet later, we can swap it in.
- If you want direnv or other per-shell hooks, they can be added similarly.

Step 4 (optional): Extend fastfetch wrappers to recognize Nushell

- Your current wrappers detect parent process and exec fastfetch via that shell
  (zsh, bash, fish). Add a case for Nushell:

```
# In modules/home/scripts/ff*.nix where shell detection occurs:
case "$parent_name" in
  *zsh*) shell="${pkgs.zsh}/bin/zsh" ;;
  *bash*) shell="${pkgs.bash}/bin/bash" ;;
  *fish*) shell="${pkgs.fish}/bin/fish" ;;
  *nu*|*nushell*) shell="${pkgs.nushell}/bin/nu" ;;
  *) shell="$(command -v "$parent_name" 2>/dev/null || true)" ;;
	esac
```

This ensures Fastfetch reports “nu” when invoked from Nushell.

Alias/function parity review (ensure consistent UX)

- Review the following files to mirror relevant aliases/functions in Nushell where possible:
  - ~/ddubsos/modules/home/zsh/zshrc-personal
  - ~/ddubsos/modules/home/zsh/default.nix
  - ~/ddubsos/modules/home/shells/eza.nix
- Notes:
  - zoxide is integrated in current shells; cdi is aliased to zi in eza.nix for compatibility.
  - Replicate equivalent behaviors in Nushell (aliases/functions above) so switching shells preserves muscle memory.

Validation steps (when implementing later)

1. Pick a host and set shellChoice = "nushell" in hosts/<host>/variables.nix.
2. Rebuild Home Manager / system.
3. Open a new Nu session (nu) and validate:
   - eza aliases: run ls/ll/la/tree.
   - zoxide: run zi to invoke interactive jump; run z dir-name to jump directly.
   - If using Starship: validate the prompt loaded.
4. Run ff/ff1/ff2 inside Nushell and confirm Fastfetch shows the Shell as “nu”.

Rollback / notes

- To revert, change shellChoice back to "zsh" (or others) in the host variables
  and rebuild.
- No global behavior is changed until you explicitly select Nushell via
  shellChoice.

Potential pitfalls / considerations

- Nushell alias semantics are different from bash/zsh; the supplied aliases work
  for common eza use cases.
- If you change zoxide’s command name globally (e.g., "--cmd cd"), your "zi"
  alias in eza.nix (zi = "cdi") may diverge from Nu’s zi above. The Nushell
  functions here use zoxide directly and are unaffected by that global flag.
- If you want zoxide’s official Nu integration instead of custom functions, we
  can replace the functions with zoxide’s init script (requires checking current
  zoxide releases for the exact snippet).
- If you want Nushell to be the system default login shell, you’ll also need to
  change user shell in NixOS user config. This plan only covers Home Manager
  interactive shell behavior and configuration.

Summary of edits to make (when ready)

- hosts/default/variables.nix: add `shellChoice = "zsh";` (and override per
  host).
- modules/home/default.nix: import conditional `shellImports` based on
  shellChoice.
- Create modules/home/shells/nushell.nix with eza aliases, zoxide functions,
  optional Starship.
- Update ff wrappers ~/ddubsos/modules/home/cli/fastfetch to detect and exec via
  Nushell.

End of plan.
