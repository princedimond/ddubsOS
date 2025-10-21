# ddubsOS Refactor Status — 2025-09-06

This document tracks actual progress against the plan in docs/ddubos-refactor-plan.md.

Summary
- Branch: ddubos-refactor
- Goal: introduce host-based flake outputs, improve installer/ZCLI, add formatting/checks, and set a stable baseline at v2.4.

Completed vs Plan
1) Flake host architecture refactor
- Done (additive, non-breaking). Host-based outputs now generated from hosts/ and merged with profile outputs.
- Fixed module import duplication by relying on profiles/<profile> to import hosts/<host> — avoids double importing hosts.

2) Installer changes
- Done (phase 1): added flags --host, --profile, --build-host, --non-interactive.
- Default behavior remains building profile output; --build-host opts into host output.

3) ZCLI extensions
- Done (phase 1): hosts-apps (existing), add-host, del-host, rename-host, hostname set.
- Tightened add-host to stop editing hosts/<h>/default.nix; scaffold only and advise using update-host to set flake host/profile.

4) Linter/formatter and checks
- Done: Added formatter (alejandra) and flake checks to outputs; nix fmt works.

5) Versioning and migration
- Done: created Stable-v2.4 and bumped DDUBSOS_VERSION to 2.4 in system.nix and README/FAQ banners.
- Done: added docs/upgrade-from-2.4.md.

6) HM useGlobalPkgs toggle
- Disabled for now: hmUseGlobalPkgs is set to false due to issues; do not enable.

7) Documentation and Spanish
- Pending: integrate new sections into README/FAQ and the wiki (English/Spanish) re: host outputs and installer flags.
- Completed docs:
  - docs/upgrade-from-2.4.md (this upgrade path)
  - docs/ddubos-refactor-plan.md (previously committed)
  - docs/ddubos-deep-analysis-YYYY-MM-DD.md (previous analysis)
  - docs/ddubos-refactor-status.md (this file)

Open Items / Next
- Validate ZCLI end-to-end (see test plan) and adjust UX messages.
- Optionally add a host→default profile map in flake.nix to preselect GPU profile per host.
- CI: integrate flake check in GitLab/GitHub CI and optionally build selected host outputs.
- Document: update README/FAQ with new commands and host build instructions; Spanish versions too.

Changelog notes
- Flake: host outputs added; mkHostConfig uses profiles/<profile> to import hosts/<host>.
- Installer: added --non-interactive path for automated use.
- ZCLI: added host management; add-host no longer edits host default.nix; use update-host instead.
- HM: useGlobalPkgs disabled (set false) in this branch; do not enable.

