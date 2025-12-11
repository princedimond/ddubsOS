# Hyprland Window Rules: Next-Gen Named Syntax (windowrules-ng.nix)

This repo now has a Hyprland window-rules module that targets the upcoming
windowrules rewrite:

- Hyprland PR: https://github.com/hyprwm/Hyprland/pull/12269
- Wiki: Configuring → Window Rules (new syntax with `windowrule { .. }`)

The new module lives at:

- `modules/home/hyprland/windowrules-ng.nix`

and was generated from the legacy rules in:

- `modules/home/hyprland/windowrules.nix`

via the helper script:

- `~/Projects/ddubs/hyprrulefix/fix.py` (invoked with `--named`)

## 1. New syntax recap

The rewrite changes window rules to a property/effect model, with explicit
match props and named blocks.

Example from the new spec:

```ini path=null start=null
windowrule {
  name = apply-something
  match:class = my-window

  border_size = 10
}
```

Key points:

- `windowrule` can be a **named block** (`windowrule { ... }`) instead of only
  `windowrule = ...` lines.
- Inside each block:
  - **Props** are prefixed with `match:` and control which windows the rule
    applies to (e.g. `match:class`, `match:title`, `match:tag`, `match:xwayland`).
  - **Effects** describe what to do (e.g. `float`, `size`, `center`,
    `opacity`, `workspace`, `border_size`, `idle_inhibit`).
- All props in a block must match for the effects to apply.

The `fix.py` script takes old-style `windowrule`/`windowrulev2` lines and
rewrites them into this new named-block style, renaming keys/values and
normalizing booleans along the way.

## 2. How windowrules-ng.nix was produced

The pipeline for building `windowrules-ng.nix` was:

1. Extract the legacy rule strings from `modules/home/hyprland/windowrules.nix`
   into a temporary Hyprland-style config file (`/tmp/hypr-windowrules-legacy.conf`)
   with lines like:

   ```ini path=null start=null
   windowrule = float, class:^(foot-floating)$
   windowrulev2 = noborder, class:^(org\\.qt-project\\.qml)$, title:^(Wallpapers)$
   ```

2. Run the converter script with named-block output enabled:

   ```bash path=null start=null
   python ~/Projects/ddubs/hyprrulefix/fix.py /tmp/hypr-windowrules-legacy.conf --named
   ```

   This does the following:

   - Parses **selectors** (pieces containing `:`) and normalizes them:
     - `class:` → `match:class = ...`
     - `title:` → `match:title = ...`
     - `initialClass:` → `match:initial_class = ...`
     - `initialTitle:` → `match:initial_title = ...`
     - `tag:browser*` → `match:tag = browser*`
     - `xwayland:1` → `match:xwayland = 1`
     - `fullscreen:1` → `match:fullscreen = 1`
   - Parses **flags/effects** (no `:`) and normalizes them using two maps:
     - Key replacements, e.g.:
       - `bordersize` → `border_size`
       - `idleinhibit` → `idle_inhibit`
       - `noanim` → `no_anim`
       - `noborder` → `border_size` + default `0`
       - `suppressevent` → `suppress_event`
       - `nofocus` → `no_focus`
       - `noinitialfocus` → `no_initial_focus`
       - `noblur` → `no_blur`
       - `ignorealpha`/`ignorezero` → `ignore_alpha`
     - Default values for valueless flags, e.g.:
       - `float` → `float = on`
       - `center` → `center = on`
       - `no_blur` → `no_blur = on`
       - `no_focus` → `no_focus = on`
       - `border_size` (from `noborder`) → `border_size = 0`
   - Merges rules that have identical selector sets into a single block and
     assigns a stable name like `windowrule-23`.

3. Take the resulting `windowrule { ... }` blocks and embed them verbatim into
   `modules/home/hyprland/windowrules-ng.nix` under `extraConfig`, preserving
   the existing monitor lines.

The result is a pure Hyprland config fragment that uses only the new syntax
and can be dropped into any Hyprland setup that supports the rewrite.

## 3. How to switch ddubsOS to the NG rules

1. **Ensure your Hyprland build supports the new syntax.**

   - You should be on a Hyprland version that contains PR #12269 or later.
   - The official wiki page for "Window Rules" should show `windowrule { ... }`
     / `match:`-style props.

2. **Switch the Hyprland module import to windowrules-ng.nix.**

   Edit `modules/home/hyprland/default.nix` and swap the import:

   ```nix path=null start=null
   imports = [
     # ...
-    ./windowrules.nix
+    ./windowrules-ng.nix
     # ...
   ];
   ```

   Leave `windowrules.nix` in place as a reference/backup until you are
   confident the new rules behave correctly.

3. **Rebuild your system / home-manager config.**

   From the ddubsOS repo:

   ```bash path=null start=null
   zcli rebuild
   # or the equivalent nixos-rebuild / nh command you normally use
   ```

4. **Verify behavior.**

   - Use `hyprctl clients` / `hyprctl activewindow` to inspect classes, titles,
     tags, and fullscreen/XWayland flags.
   - Confirm that windows land on the same workspaces as before (e.g. IM on 3,
     browsers on 2, OBS on 10), and that opacity/floating/rounding behavior
     matches the legacy config.

If anything looks off, you can diff the relevant `windowrule { ... }` block in
`windowrules-ng.nix` against the legacy string in `windowrules.nix` and adjust
props/effects by hand.

## 4. Modifying or adding rules going forward

When editing rules in the new world, follow these guidelines:

- Put all **match props** first inside the block:

  ```ini path=null start=null
  windowrule {
    name = windowrule-myapp
    match:class = ^(my-app)$
    match:title = ^(My App - Project)$

    float = on
    size = 60% = 60%
    center = on
  }
  ```

- Keep effect naming consistent with `fix.py` and the wiki:
  - Use `border_size`, not `bordersize`.
  - Use `idle_inhibit`, not `idleinhibit`.
  - Use `no_blur`, `no_focus`, `no_initial_focus`, etc.
- For boolean-ish effects, prefer the same style the converter uses:
  - `float = on`, `center = on`, `no_blur = on`, etc.

If you later change or add legacy-style rules in `windowrules.nix`, you can
re-run the same extraction + `fix.py --named` pipeline to regenerate a fresh
set of NG rules and drop them back into `windowrules-ng.nix`.
