# Plan: Make Hyprland selectable at install time and via variables.nix

Goal
- Hyprland is currently effectively “on by default” in ddubsOS. Make it a selectable option alongside dwm, cosmic, bspwm, gnome, wayfire (and Mango if enabled), with Hyprland still the default.
- Expose selection in hosts/<host>/variables.nix, and make install-ddubsos.sh prompt for the default desktop at install time.

Current state in ddubsOS
- Hyprland is always imported in the Home Manager layer:

```nix path=/home/dwilliams/ddubsos/modules/home/default.nix start=30
    #Hyprland
    waybarChoice
    ./wlogout
    ./hyprland
    ./hyprpanel.nix
```

- SDDM default session is hardcoded to Hyprland:

```nix path=/home/dwilliams/ddubsos/modules/core/xserver.nix start=11
  services.displayManager.defaultSession = "hyprland";
```

Proposed approach
- Introduce two complementary controls in hosts/<host>/variables.nix:
  1) defaultDesktop: a string enum selecting the login default ("hyprland" by default; others: "dwm", "cosmic", "bspwm", "gnome", "wayfire", "mango")
  2) Per-desktop enable booleans to install their modules/configs (already exist for gnomeEnable, bspwmEnable, dwmEnable, wayfireEnable, cosmicEnable). Add hyprlandEnable and reuse enableMangowc from the Mango plan.

Trade-offs
- Single enum-only install: simpler but less flexible (you can’t preinstall multiple DEs). Not recommended.
- Enum + booleans: slightly more config but lets users install multiple DEs and still pick a default. Recommended.

Planned changes
1) Add variables to hosts/default/variables.nix (and new hosts when created)

```nix path=null start=null
# Desktop selection
# The session name must match the desktop’s .desktop session identifier used by SDDM.
# Valid values: "hyprland" (default), "dwm", "cosmic", "bspwm", "gnome", "wayfire", "mango"
defaultDesktop = "hyprland";

# Install toggles
hyprlandEnable = true;   # keep current behavior by default
# Existing: gnomeEnable, bspwmEnable, dwmEnable, wayfireEnable, cosmicEnable
# From Mango plan: enableMangowc = false;
```

2) Make Hyprland imports conditional in modules/home/default.nix
- Only import Hyprland modules when hyprlandEnable is true.

```nix path=null start=null
{ host, inputs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) hyprlandEnable;
in {
  imports = [
    # ... existing imports ...
  ]
  ++ (if hyprlandEnable then [
    waybarChoice
    ./wlogout
    ./hyprland
    ./hyprpanel.nix
  ] else [ ]);
}
```

3) Make default session configurable in modules/core/xserver.nix
- Replace the hardcoded Hyprland default with host variable defaultDesktop.
- Ensure the session name matches the .desktop identifier. Known values:
  - hyprland: "hyprland"
  - dwm: "dwm"
  - wayfire: "wayfire"
  - gnome: "gnome" (NixOS/SDDM resolves to GNOME session)
  - cosmic: likely "cosmic" (verify the greeter/session name used by NixOS’s cosmic desktop)
  - mango (MangoWC): "mango" (from upstream providedSessions)

```nix path=null start=null
{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) defaultDesktop;
in {
  services.displayManager.defaultSession = defaultDesktop;
}
```

4) Guard DE services by existing booleans (already present)
- gnome/cosmic enable toggles are in modules/core/xserver.nix; keep as-is but consider auto-deriving them from defaultDesktop if desired.

Optional: auto-derive enables from defaultDesktop
- For convenience you can auto-enable the chosen default and leave others as configured:

```nix path=null start=null
{ host, ... }:
let
  vars = import ../../hosts/${host}/variables.nix;
  inherit (vars) defaultDesktop;
  mkDefault = name: (defaultDesktop == name);
in {
  services.desktopManager.gnome.enable = vars.gnomeEnable || mkDefault "gnome";
  services.desktopManager.cosmic.enable = vars.cosmicEnable || mkDefault "cosmic";
  # bspwm/dwm/wayfire are imported via HM conditionals in modules/home/default.nix
}
```

5) Update install-ddubsos.sh to prompt for the default desktop
- Add a new interactive prompt early in the script (after hostname and GPU profile) to select the default desktop.
- Default selection should be hyprland.
- Based on the selection, set defaultDesktop and toggle booleans accordingly in hosts/$hostName/variables.nix.
- Ensure SDDM defaultSession is updated via variables (the module change in step 3 makes this automatic).

Example prompt and write-back (pseudocode; integrate into the existing style):

```bash path=null start=null
print_header "Default Desktop Selection"
cat <<'EOF'
Available options:
  hyprland (default)
  dwm
  cosmic
  bspwm
  gnome
  wayfire
  mango  # from MangoWC; appears if enableMangowc will be used
EOF
read -rp "Choose default desktop [ hyprland ]: " defaultDesktop
[ -z "$defaultDesktop" ] && defaultDesktop="hyprland"

# normalize and set flags
case "$defaultDesktop" in
  hyprland)
    sed -i 's/^\s*hyprlandEnable = .*/  hyprlandEnable = true;/' ./hosts/$hostName/variables.nix
    ;;
  dwm)
    sed -i 's/^\s*dwmEnable = .*/  dwmEnable = true;/' ./hosts/$hostName/variables.nix
    ;;
  cosmic)
    sed -i 's/^\s*cosmicEnable = .*/  cosmicEnable = true;/' ./hosts/$hostName/variables.nix
    ;;
  bspwm)
    sed -i 's/^\s*bspwmEnable = .*/  bspwmEnable = true;/' ./hosts/$hostName/variables.nix
    ;;
  gnome)
    sed -i 's/^\s*gnomeEnable = .*/  gnomeEnable = true;/' ./hosts/$hostName/variables.nix
    ;;
  wayfire)
    sed -i 's/^\s*wayfireEnable = .*/  wayfireEnable = true;/' ./hosts/$hostName/variables.nix
    ;;
  mango)
    # enableMangowc introduced by Mango plan
    sed -i 's/^\s*enableMangowc = .*/  enableMangowc = true;/' ./hosts/$hostName/variables.nix
    ;;
  *)
    echo "Unknown desktop: $defaultDesktop" ;;
fi

# write defaultDesktop key (add if missing)
if grep -q '^\s*defaultDesktop\s*=\s*' ./hosts/$hostName/variables.nix; then
  sed -i "s|^\s*defaultDesktop\s*=\s*\".*\";|  defaultDesktop = \"$defaultDesktop\";|" ./hosts/$hostName/variables.nix
else
  # append at end of file
  echo "  defaultDesktop = \"$defaultDesktop\";" >> ./hosts/$hostName/variables.nix
fi
```

Notes and validations
- Keep Hyprland as the default selection to preserve current experience.
- If multiple DEs are enabled, users can still pick other sessions at SDDM login; defaultDesktop only controls the preselected session.
- Session identifiers must be verified for cosmic (and any newly added DEs). For Mango, use "mango" as provided by upstream.
- Ensure no duplicate imports or conflicting settings when multiple DE flags are enabled.

zcli and docs updates
- zcli: add commands to set default desktop and optionally toggle enables:
  - zcli desktop set-default hyprland|dwm|cosmic|bspwm|gnome|wayfire|mango
  - zcli desktop enable <name>
  - zcli desktop disable <name>
- Docs: Add a “Desktop Selection” section to README/docs describing variables.nix flags, defaultDesktop, and how to switch post-install via zcli.

Rollout checklist
- Implement variables.nix changes (defaultDesktop, hyprlandEnable) and update the default template.
- Make HM Hyprland import conditional.
- Make xserver.nix use defaultDesktop.
- Extend install-ddubsos.sh to prompt and persist the choice.
- Build each profile with different defaults to ensure SDDM shows the correct session by default.

