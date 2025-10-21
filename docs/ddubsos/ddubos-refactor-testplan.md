# ddubsOS Refactor Test Plan — 2025-09-06

This test plan verifies the refactor branch (ddubos-refactor) features: host-based flake outputs, installer flags, and ZCLI host management.

How to run
- All commands assume PWD is the repo root (~/ddubsos) on a test machine or VM.
- Prefer to test in a VM or non-critical host.

1) Flake structure and checks
- Run style and basic checks:
  - nix flake check --print-build-logs
  Expect: Alejandra formatting passes; no structural errors.

- List flake outputs and confirm host entries exist (hostnames from hosts/):
  - nix flake show
  Expect: nixosConfigurations includes both legacy profile names (amd, intel, nvidia, nvidia-laptop, vm) and all host names.

2) Host-based builds (dry-run evaluation)
- Evaluate a host output without switching:
  - nix build .#<host> --no-link
  Expect: Derivations evaluate/build; no duplicate module errors.

- Evaluate a profile output without switching:
  - nix build .#amd --no-link
  Expect: Derivations evaluate/build; no duplicate module errors.

3) Installer flags
- Non-interactive host build (dry run of flow without actually switching):
  - ./install-ddubsos.sh --host testbox --profile vm --build-host --non-interactive
  Expect:
    - Creates hosts/testbox/ and populates *.nix files
    - Sets flake host=testbox and profile=vm
    - Attempts to build .#testbox

- Interactive detection and profile override:
  - ./install-ddubsos.sh (follow prompts; override detected profile)
  Expect:
    - When detection is wrong, manual selection is honored

4) ZCLI host management
- Add host:
  - zcli add-host my-laptop amd
  Expect: hosts/my-laptop/ created; no edits to hosts/my-laptop/default.nix; suggestion printed to use update-host

- Update flake host and profile:
  - zcli update-host my-laptop amd
  Expect: flake.nix host and profile lines updated

- Rename host:
  - zcli rename-host my-laptop my-notebook
  Expect: hosts/my-laptop moved to hosts/my-notebook; if flake host was my-laptop, it is updated to my-notebook

- Delete host:
  - zcli del-host my-notebook (confirm when prompted)
  Expect: hosts/my-notebook removed; git add staged

- Set hostname (flake only):
  - zcli hostname set ixas
  Expect: flake host updated to ixas; warns if hosts/ixas does not exist

5) Regression checks
- Verify existing nh rebuild flows still function:
  - zcli rebuild
  - zcli rebuild-boot
  - zcli update
  Expect: Command paths unchanged and functional.

- Verify no duplicate imports:
  - If errors like "option ... defined multiple times" appear, confirm only profiles/<profile> import hosts/<host>, and flake does not separately import hosts/<host> in mkHostConfig.

7) Documentation alignment
- Ensure README/FAQ contain updated guidance (pending step):
  - Add a short section on host-based targets and installer flags.
- Verify upgrade-from-2.4.md flows are accurate.

8) Optional CI checks
- Run nix fmt locally and ensure no diffs.
- Consider adding CI to run: nix flake check, nix build .#<sample-host> --no-link.

Pass criteria
- All above steps complete without errors on a test machine or VM.
- Host-based builds work, installer flags functional, zcli host commands behave as designed.
- Toggling HM global pkgs works and rebuilds succeed.

