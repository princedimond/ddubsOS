# Plan: Integrate MangoWC (Mango) into ddubsOS

This document proposes how to add and gate MangoWC (repository: DreamMaoMao/mangowc; package/module name: “mango”) into ddubsOS, controlled by a host-level variable enableMangowc.

Scope
- Add Mango as an optional Wayland compositor alongside existing options (Hyprland, Wayfire, etc.).
- Introduce host variable enableMangowc to toggle integration.
- Wire up NixOS and Home Manager modules from the upstream flake.
- Capture required dependencies and suggested applications from upstream.
- Note ancillary updates required in zcli and documentation.

Summary of upstream flake (mangowc)
- Inputs: nixpkgs, flake-parts, mmsg, scenefx
- Exposes:
  - nixosModules.mango: programs.mango.enable toggles system integration. When enabled, it:
    - Installs mango in environment.systemPackages (and mmsg if provided)
    - Enables xdg-desktop-portal-wlr, sets xdg.portal.configPackages = [ mango ]
    - Enables security.polkit and programs.xwayland
    - Adds services.displayManager.sessionPackages = [ mango ]
    - Enables services.graphical-desktop by default
  - hmModules.mango: wayland.windowManager.mango options for config and autostart
  - packages.default = mango (build requires patched wlroots and scenefx; upstream flake handles this)

Required and suggested applications (from upstream)
- Build/runtime deps (handled by upstream Nix packaging):
  - wlroots 0.19 with upstream’s patches, scenefx, wayland, wayland-protocols, libinput, libxkbcommon, pixman, pcre2, libGL; XWayland optional
- Suggested tools for a complete desktop:
  - Launchers: rofi, bemenu, wmenu, fuzzel
  - Terminals: foot, wezterm, alacritty, kitty, ghostty
  - Status bars: waybar (preferred), eww, quickshell, ags
  - Wallpaper: swww or swaybg
  - Notifications: swaync, dunst, mako
  - Portals: xdg-desktop-portal, xdg-desktop-portal-wlr, xdg-desktop-portal-gtk
  - Clipboard: wl-clipboard, wl-clip-persist, cliphist
  - Gamma/night light: wlsunset, gammastep
  - Misc: xfce-polkit, wlogout
- Extra utilities referenced in the wiki for certain features:
  - wlr-randr, wlr-dpms
  - For recording/sharing: pipewire, pipewire-pulse, xdg-desktop-portal-wlr

Integration plan for ddubsOS
1) Add the flake input in ddubsOS flake.nix
   - Rationale: Consume upstream module/package directly.
   - Change: Add input and follow nixpkgs for consistency.

   ```nix path=null start=null
   inputs = {
     # ... existing inputs ...
     mango = {
       url = "github:DreamMaoMao/mangowc"; # upstream repo
       inputs.nixpkgs.follows = "nixpkgs";
     };
   };
   ```

2) Wire NixOS module into system configurations
   - Rationale: Allow enabling Mango via programs.mango.enable.
   - Change: Append inputs.mango.nixosModules.mango to the NixOS modules set for all GPU profiles (so it’s available to toggle per host).

   Example in mkNixosConfig modules list:
   ```nix path=null start=null
   modules = [
     # ...existing modules...
     inputs.mango.nixosModules.mango
   ];
   ```

3) Wire HM module into user session
   - Rationale: Provide an easy path for user config/autostart via Home Manager when Mango is enabled.
   - Change: Include inputs.mango.hmModules.mango in modules/home/default.nix conditionally when Mango is selected or enabled.

   In modules/home/default.nix, extend imports with a conditional:
   ```nix path=null start=null
   imports = [
     # existing home imports
   ]
   ++ (if enableMangowc then [ inputs.mango.hmModules.mango ] else [ ]);
   ```

   And allow per-user Mango config when enabled (example only; actual configuration is user/host specific):
   ```nix path=null start=null
   wayland.windowManager.mango = {
     enable = true;
     systemd = {
       enable = true;
       xdgAutostart = true;
     };
     settings = ''
       # Put mango config.conf content here or source from file
     '';
     autostart_sh = ''
       # Waybar, notifications, wallpaper, clipboard, etc.
       waybar &
       swaync &
       wl-clip-persist --clipboard regular --reconnect-tries 0 &
       wl-paste --type text --watch cliphist store &
       swww init || true
     '';
   };
   ```

4) Host variable: enableMangowc
   - Rationale: Toggle Mango integration per host alongside other DE switches
   - Change: Add a boolean to hosts/<host>/variables.nix and to the default template at hosts/default/variables.nix

   ```nix path=null start=null
   # MangoWC (Mango) integration
   enableMangowc = false; # set true to enable Mango on this host
   ```

5) Conditionally activate Mango system module
   - Rationale: When enableMangowc is true, enable the upstream NixOS module to provide session and portals.
   - Change: In a central NixOS module that already reads host vars (e.g., a new small module under modules/core or existing profile module), set:

   ```nix path=null start=null
   { host, pkgs, inputs, ... }:
   let inherit (import ../../hosts/${host}/variables.nix) enableMangowc; in
   {
     programs.mango.enable = enableMangowc;
     # no further plumbing required; upstream module:
     # - sets xdg portals
     # - provides a session in services.displayManager.sessionPackages
     # - enables xwayland/polkit by default
   }
   ```

6) Default session selection interaction
   - Mango’s Nix package declares providedSessions = [ "mango" ].
   - Ensure services.displayManager.defaultSession is set to the desired desktop (see Hyprland plan). If Mango is selected as default desktop, set defaultSession = "mango".
   - If multiple desktops are installed, SDDM will list multiple sessions; defaultSession chooses the initially selected one.

7) Add suggested tooling when Mango is enabled
   - Provide a minimal recommended set when enableMangowc is true, installed via system or home packages. For example:

   ```nix path=null start=null
   { host, pkgs, ... }:
   let inherit (import ../../hosts/${host}/variables.nix) enableMangowc; in
   {
     environment.systemPackages = lib.mkIf enableMangowc [
       pkgs.waybar
       pkgs.rofi
       pkgs.swaybg # or swww
       pkgs.swaync # or dunst/mako
       pkgs.wl-clipboard pkgs.wl-clip-persist pkgs.cliphist
       pkgs.wlsunset # or gammastep
       pkgs.wlogout
     ];
     # xdg-desktop-portal-wlr and polkit are enabled by the Mango NixOS module already
   }
   ```

8) Documentation and zcli updates
   - zcli: add a subcommand to toggle Mango enablement and/or set the default desktop (see Hyprland plan). For example:
     - zcli desktop set-default mango
     - zcli desktop enable mango
   - Documentation:
     - README/docs: Add a Mango section with an overview and how to enable via variables.nix and select it as default session.
     - Include the list of suggested tools and how to autostart waybar/notifications/clipboard in Mango’s HM settings.

9) Testing checklist
- nix flake check/build for the profiles that include Mango
- Ensure SDDM session file “mango.desktop” is present and defaultSession="mango" works
- Verify xdg-desktop-portal-wlr and polkit are enabled (login + portal detection)
- Verify mmsg binary availability (ipc helper) via which mmsg
- Validate autostart of waybar/notifications/clipboard from HM module

Rollout steps
1. Implement steps (1)-(5) in a feature branch.
2. Add (6)-(8) in the same branch and update docs.
3. Build a test profile with enableMangowc=true; confirm the Mango session appears and is selectable in SDDM.
4. Merge after validation.

