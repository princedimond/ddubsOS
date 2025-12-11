# 📋 ddubsOS Changelog

> **A comprehensive history of changes, improvements, and updates to ddubsOS**

---

# 🚀 \*\*Current Release - ddubsOS v2.7.2

## Updated:

- `nxivim` theme to `tokyonight`
- `alejandra` as nix formatter in `flake.nix`
- Alejandra also in `nixvim.nix`
- Ran `nix fmt ./` to revise all files

# 🚀 \*\*Current Release - ddubsOS v2.7.1

## Updated:

- `oxwm-parser` for new `config.lua` format. (again)
- `oxwm` configuration with bindings my apps
- configuration to only install current build of Warp Terminal
- `kitty.nix` Added desktop file for `kitty-bg`
  - Now kitty with random wallpaper can run from launcher
- `fonts.nix` Re-enabled `symbola` font. Builds OK again
- Noctalia-shell to v3.5.0-git
- Thanks to @mugdad for figuring it out
- Noctalia docs show `qs -c noctalia-shell`
  - This results in older version being loaded
  - Just run `exec-once = noctala-shell` instead
  - This gets you current commit, now shows in `about:`
  - Also need to change the keybinds to `noctalia-shelll ipc call...`

## Added:

- Image Preview to `nixvim` `leader fm` for find media files
- `dino` and `gajim` Jabber XMPP clients
- `ff3` A simple, and elegent fastfetch config
- `Nero Hyprland` theme to `vscode.nix`
- `code-runner` plugin to `vscode.nix`
- `antigravity` IDE (based on vscodium)
- Nero Hyprland theme to vscode
- `WindowRules-ng.nix` to prepare for Hyprland 0.53 changes
- Hyprland animations from Jak's dotfiles
- Animations:
  - hyde optimized
  - ml4w classic
  - ml4w fast
  - ml4w high
  - Mahaveer-me-1
  - Mahaveer-me-2

## Removed:

- Home Manager setting defaults for `noctalia`
  - It would just reset to them after reboot or re-login

## Fixed:

- `kb_variants` was set to `us` layout by default
- Dropdown Terminal
- GPU profies getting defaulted to AMD

## Features:

## Option to build Hyprland from source or NixPkgs (2025-11-19)

- `hyprlandSource` in `hosts/<host>/variables.nix` to enable source build

## 🧱 OXWM (X11 tiling WM) integration (2025-11-07)

- Added optional OXWM desktop integration.
  - Home Manager module: `modules/home/gui/oxwm.nix` (installs oxwm + X11
    utilities like rofi, dunst, picom, feh, xclip, xdotool, xrandr, etc.)
  - User polkit agent enabled for X11 sessions via polkit-gnome
  - Host toggle: set `oxwmEnable = true;` in `hosts/<host>/variables.nix`
  - System session: upstream `oxwm.nixosModules.default` included for host-first
    builds (xsessions entry)
  - Project: https://github.com/tonybanters/oxwm

## 🧬 Folding@home client (2025-11-07)

- Added Folding@home client to global packages: `fahclient`
- Team: PewDiePie — ID `1066966`

## ⌨️ Hyprland: Layout-aware SUPER+J/K (2025-11-05)

- New dynamic cycle bindings with clear labels:
  - `$modifier, J, Cycle to next window, cyclenext`
  - `$modifier, K, Cycle to previous window, cyclenext, prev`
- Behavior adapts to the active layout at login and after layout swaps:
  - Dwindle: native cyclenext bindings
  - Master: uses `layoutmsg` cyclenext/cycleprev under the hood
- Implementation:
  - `hypr-layout-init` reads `general:layout` and (un)binds J/K appropriately;
    run on login via `exec-once`
  - `swap_layout` toggles master/dwindle and re-runs `hypr-layout-init`
  - Default layout remains declarative in Nix; runtime init reconciles to the
    live value

## 🔧 ** Older Bug Fixes & Maintenance**

### 🗂️ ** Updated FAQ **

- Rewrite of `FAQ.md` and `FAQ.es.md`
- Table of contents for easier navigation
- Redid formatting for easier reading

### 📦 **Nixpkgs Alias Deprecation Fixes (2025-10-31)**

- **Issue**: `nix flake check` was failing due to deprecated package aliases in
  newer nixpkgs
- **Root cause**: nixpkgs deprecated several package names in favor of new ones,
  causing evaluation errors
- **Fixes applied**:
  - `noto-fonts-emoji` → `noto-fonts-color-emoji` (modules/core/fonts.nix:28)
    - Updated due to nixpkgs package rename for color emoji support
  - `vaapiIntel` → `intel-vaapi-driver` (modules/drivers/intel-drivers.nix:19)
    - VAAPI Intel driver was renamed; new package provides same functionality
  - `vaapiVdpau` → `libva-vdpau-driver` (modules/drivers/intel-drivers.nix:20)
    - VDPAU wrapper for VA-API also renamed in latest nixpkgs
- **Input cleanup**: Removed hyprpanel from flake inputs
  - hyprpanel is now available directly from nixpkgs, eliminating need for
    separate input
  - Reduced flake complexity and avoided potential `wrapGAppsHook` version
    conflicts
- **Result**: All NixOS configurations now pass `nix flake check` successfully

### 🗑️ **Removed Problematic Host Configuration**

- **hosts/explorer**: Removed due to broken CUDA dependencies
  - Root cause: davinci-resolve and nvtopPackages.nvidia had dependencies on
    cuda12.8-cuda_cuobjdump which is marked as broken in current nixpkgs
  - This affected `nix flake check` and prevented clean builds
  - Host can be restored if CUDA package issues are resolved upstream

## 🎯 **New Features Spotlight**

### 🪐 **sway tiling window manager**

- Config from `CuerdOS`
- https://cuerdos.github.io/

### 🌐 Declarative Default Browser (XDG MIME handlers)

- New Home Manager module: `modules/home/xdg/default-apps.nix` declaratively
  sets the system default web browser using your per-host setting in
  `hosts/<host>/variables.nix`.
- Honors your `browser` variable (defaults to `google-chrome-stable`) and maps
  it to the correct `.desktop` ID, setting these handlers:
  - `x-scheme-handler/http`, `x-scheme-handler/https`, `text/html`,
    `application/xhtml+xml`
- Prevents apps (e.g., Discord or Zen) from permanently overriding
  `~/.config/mimeapps.list` — your declared defaults are re-applied on rebuild.
- Already supported browser keys (no extra steps needed):
  - `google-chrome`, `google-chrome-stable`, `firefox`, `firefox-esr`, `brave`,
    `chromium`, `vivaldi`, `floorp`, `zen`, `zen-browser`
- Zen special case: if you set the browser to Zen (keys `zen` or `zen-browser`),
  you must also enable the package because Zen is still in beta and provided via
  a flake input (built during the Nix build):
  ```nix path=null start=null
  # hosts/<host>/variables.nix
  enableZenBrowser = true;
  browser = "zen";  # or "zen-browser"
  ```
- Typical Chrome default in a host variables file:
  ```nix path=null start=null
  # hosts/<host>/variables.nix
  browser = "google-chrome-stable";
  ```
- How to add support for new browsers (e.g., Ladybird, Thorium): see the guide
  `docs/HOWTO-Add-Browser-To-Support-list.md` for step-by-step instructions to
  map a new browser key to its `.desktop` ID and update your host variables.

### 🧭 Starship prompt selection (per-host)

- New variable: `starshipChoice` in `hosts/<host>/variables.nix`
- Choose one Starship config per host by selecting a file path:
  - `../../modules/home/cli/starship.nix` (default)
  - `../../modules/home/cli/starship-1.nix`
  - `../../modules/home/cli/starship-rbmcg.nix`
- The home module now imports `starshipChoice` (similar to `waybarChoice`), and
  the hard-coded Starship import was removed from the CLI bundle.
- How to use: edit your host's `variables.nix`, set `starshipChoice` to the
  desired file, then `zcli rebuild`.

### 🪐 **COSMIC Desktop (Beta)**

- 🧩 Toggle-based enablement: Added `cosmicEnable` to hosts/<host>/variables.nix
  (default: false across all hosts and in hosts/default template)
- 🖥️ System-level integration:
  `services.desktopManager.cosmic.enable = cosmicEnable;`
  - 🚫 Greeter: `services.displayManager.cosmic-greeter.enable = false;` — SDDM
    remains the display manager; select the COSMIC session at login
- 🏠 Home Manager module: `modules/home/gui/cosmic-de.nix` installs a suite of
  COSMIC apps when enabled:
  - Apps/components: `cosmic-term`, `cosmic-settings`, `cosmic-files`,
    `cosmic-edit`, `cosmic-randr`, `cosmic-idle`, `cosmic-comp`, `cosmic-osd`,
    `cosmic-bg`, `cosmic-applets`, `cosmic-store`, `cosmic-player`,
    `cosmic-session`
  - Protocols/assets: `cosmic-protocols`, `cosmic-icons`,
    `cosmic-workspaces-epoch`, `cosmic-settings-daemon`, `cosmic-wallpapers`,
    `cosmic-screenshot`, `xdg-desktop-portal-cosmic`
- 📘 Docs: Project guide updated with COSMIC details and import mechanics
- ⚠️ Note (2025-08-27): COSMIC DE is in Alpha. Expect rapid changes and
  occasional breakage; use accordingly.

### 🧰 **ZCLI: Refactor and Settings Management**

- Modular dispatcher with feature modules and shared libs
  - Entry binary generated via Nix at modules/home/scripts/zcli.nix
  - Features split under features/; common libs under lib/
- Editable settings with validation and backups
  - `zcli settings set <attr> <value> [--dry-run]`
  - Validates supported keys for `browser` and `terminal` via curated maps
  - Validates file paths for `stylixImage`, `waybarChoice`, `animChoice`
  - Always creates timestamped backups; `--dry-run` prints intended changes
- Discoverability utilities
  - `zcli settings --list-browsers`
  - `zcli settings --list-terminals`
- Hosts-specific applications view
  - `zcli hosts-apps` lists host-only packages from
    hosts/<host>/host-packages.nix
- Quality-of-life
  - `zcli upgrade` is an alias for `zcli update`

- Recent enhancements (v1.0.4+)
  - Settings view refinements
    - Boolean sections now display variable names (e.g., gnomeEnable) instead of
      human labels
    - Removed the "(settable attributes)" suffix from section headers
  - Terminal toggles and guardrails
    - New booleans: `enableWezterm` and `enableGhostty` with conditional imports
      in modules/home/default.nix
    - `zcli settings set terminal <key>` auto-enables the corresponding toggle
      when applicable:
      - `alacritty` → `enableAlacritty = true`
      - `ptyxis` → `enablePtyxis = true`
      - `wezterm` → `enableWezterm = true`
      - `ghostty` → `enableGhostty = true`
    - `--dry-run` prints intended auto-enables without writing
  - Browser guardrail
    - Refuses to set `browser` unless the corresponding command is available on
      PATH
    - Prints a helpful error instructing to install the browser first
  - Help updates
    - Help text now lists the new booleans (including `enableWezterm` and
      `enableGhostty`) in the settings section

### 🎬 **Animated Wallpaper Picker (awp-menu) and CLI (awp)**

### 🖼️ Quickshell Wallpaper Picker (qs-wallpapers) + Apply (qs-wallpapers-apply)

### 🎥 Quickshell Video Wallpaper Picker (qs-vid-wallpapers) + Apply (qs-vid-wallpapers-apply)

- New Qt/QML video wallpaper picker with video-only process awareness and
  controls
  - Status badge highlights MPVPaper: ACTIVE with a brighter, 3D pill; INACTIVE
    is dimmed
  - "Stop Video Wallpaper" button terminates only mpvpaper instances that are
    playing videos (image-only sessions are preserved)
  - Default "Disable sound" toggle with a 3D-styled control; toggle emits
    AUDIO:ON/OFF to the shell
- Apply wrapper honors audio setting and launches mpvpaper accordingly (adds
  --no-audio unless AUDIO:ON)
- Visual polish and compositor integration
  - Frameless, shadowless window; Hyprland windowrulev2 adds
    noblur/noborder/rounding 12
  - More opaque frame/header for readability on blurred backgrounds
- Detection is robust: search all mpvpaper args (ignoring -o and its value) for
  video file extensions
- Post-stop refresh: the picker waits briefly and relaunches to show updated
  status after stopping

- Native Qt/QML (Quickshell) thumbnail picker for static wallpapers with a clean
  UI:
  - Frameless, transparent window; inner light-blue 2px rounded frame; drop
    shadow
  - Grid of thumbnails with hover highlight; filenames under each image
  - ESC to exit; centered grid with balanced margins; tile backgrounds are
    transparent
- Backends supported via qs-wallpapers-apply:
  - mpvpaper (default), swww, hyprpaper
  - Robust startup: stops conflicting daemons, waits briefly for compositor
    release (mpvpaper), starts swww-daemon when needed and waits for readiness,
    generates temporary hyprpaper config (ipc on, preload + wallpaper per
    monitor)
  - QS_DEBUG logs backend steps and selected file
- Hyprland integration:
  - Window rules: float the picker; compositor border/shadow disabled for this
    window; compositor rounding applied
  - Keybinding: SUPER+SHIFT+W launches qs-wallpapers-apply (replaces prior
    waypaper/rofi-waypaper binds)
- Status (2025-09-06):
  - Selection captured; wallpaper successfully changes through apply script
  - Initial load feels slow even with thumbnail cache in place; likely
    QML/model/render cost
  - Mitigation planned: show a transient "Loading…" overlay while JSON/model
    populate; optionally batch/lazy-load

- Compact, fuzzy-searchable rofi menu to browse wallpapers in
  `~/Pictures/Wallpapers` (override with `WALLPAPERS_DIR`)
- Detects common mpv/mpvpaper-compatible formats: MP4/M4V/MP4V, WebM, AVI, AVIF,
  MKV, MOV, MPEG/MPG, WMV, AVCHD, FLV, OGV, M2TS/TS, 3GP; also includes symlinks
  in the directory
- Styled for readability: rounded corners, translucent background (works with
  compositor blur/shadows), and spacing between the search field and results
- Launches the `awp` CLI to apply the selection to all monitors; replaces
  existing mpvpaper instances to prevent duplicates
- `awp` CLI:
  - Manual launch: `awp -f <file> -m <monitor|all>`
  - Kill/replace helpers: `awp --kill`, `awp -k -m <monitor>`
  - Monitor auto-detection when `-m` is omitted (focused first, then first
    available)

### 🌟 **Doom Emacs Integration**

- 🚀 **One-command setup**: Run `get-doom` or `zcli doom install` to install all
  required packages
- 💻 **Rich language support**: C, BASH, NIX, JSON, DOCKER, YAML, CSS/HTML
- 🖥️ **Enhanced terminal**: Built-in `vterm` support for seamless terminal
  integration
- ⚡ **Evil mode**: Vim keybindings for familiar editing experience
- 🎨 **Modern interface**: Beautiful, customizable UI with extensive plugin
  ecosystem

### 🛠️ **Development Environment Module**

**🚀 Comprehensive Development Configuration with Conditional Enablement**

- 📦 **Module Architecture**: Implemented `enableDevEnv` boolean variable for
  selective development environment enablement
- 🎯 **Host Configuration**: Added `enableDevEnv = false` to all 11 host
  configurations as opt-in feature
- 🔧 **Conditional Loading**: Modified `modules/home/default.nix` to
  conditionally import `dev-env.nix` based on host variables
- 🚀 **Development Tools**: Comprehensive toolkit for modern development
  workflows:
  - 💾 **Build Tools**: cachix, nix-direnv, pre-commit, act, gh
  - 🧠 **Language Servers**: nil (Nix LSP), nixpkgs-fmt
  - 🐳 **Container Tools**: podman, buildah for containerized development
  - 🔍 **Utilities**: jless (JSON viewer), fx (JSON processor), yq (YAML/JSON
    processor)
- 🎨 **Shell Integration**: Comprehensive direnv configuration with
  zsh/bash/fish support
- 📋 **Project Templates**: Ready-to-use devenv.nix templates for Python,
  Node.js, and Rust projects
- 🔗 **Shell Aliases**: Convenient aliases (`denv`, `denv-init`, `denv-shell`,
  `denv-up`, etc.)
- 🎯 **Smart Defaults**: Cachix and direnv integration enabled by default with
  configurable options
- ⚡ **Build Optimization**: Disabled by default to avoid unnecessary build
  overhead for non-developers
- 🛡️ **Modular Design**: Self-contained Home Manager module with comprehensive
  options and documentation

### 🤖 **OpenWebUI + Ollama AI Infrastructure**

**🎯 Enhanced AI/LLM Infrastructure for NVIDIA Systems**

- 🎯 **GPU Acceleration**: Full NVIDIA GPU support with Container Device
  Interface (CDI)
- 🐳 **Docker Integration**: Containerized deployment with `--privileged` flag
  for optimal performance
- 🌐 **Web Interface**: OpenWebUI accessible at `http://localhost:3000` for
  intuitive model interaction
- 🔌 **API Access**: Ollama API available at `http://localhost:11434` for
  programmatic access
- 📊 **Management Script**: Enhanced `ollama-webui-manager` command-line tool:
  - ✅ **Status Monitoring**: Real-time service status with colorized output
  - 🎛️ **Service Control**: Start, stop, restart operations with error handling
  - 📋 **Log Management**: Integrated log viewing with service filtering
  - 🤖 **Model Operations**: Full model management capabilities:
    - 📥 **Pull Models**: Download models with
      `ollama-webui-manager pull <model>`
    - 🗑️ **Remove Models**: Safely remove models with confirmation prompts
    - 📋 **List Models**: View all downloaded models and their details
    - 🏷️ **Command Aliases**: Multiple aliases for convenience
      (`pull`/`download`/`d`, `remove`/`rm`/`delete`)
  - 🔍 **Health Checks**: API connectivity testing and version reporting
  - 💡 **User-Friendly**: Comprehensive help system and intuitive commands
- 🎯 **Profile Integration**: Available only on `nvidia` and `nvidia-laptop`
  profiles
- 🔒 **Security**: Dedicated system user/group with proper permissions
- 📦 **Persistent Storage**: Model and configuration data preserved across
  rebuilds
- 🔥 **Automatic Startup**: Services start automatically on boot with failure
  recovery

### 📊 **Glances Server Monitoring**

**🔍 Real-time System Monitoring Dashboard**

- 🌐 **Web interface**: Access monitoring at `http://IP_ADDR:62210`
- 🛠️ **Easy management**: Simple `glances-server` script with commands:
  - `glances-server start` - Launch the monitoring server
  - `glances-server stop` - Stop the monitoring server
  - `glances-server restart` - Restart the monitoring server
  - `glances-server logs` - View server logs
- 📈 **Comprehensive metrics**: CPU, memory, disk, network, and process
  monitoring
- 🎯 **Remote monitoring**: Monitor your system from any device on your network

### 📚 **Cheatsheets Library**

**🗂️ Centralized, human-friendly docs for tools and ddubsOS-specific configs**

- 🧭 **Index-first**: Quick Links and directory tree in `cheatsheets/README.md`
- 📁 **Location**: All docs live under `cheatsheets/`
- 🧩 **Initial topics**:
  - ✍️ Emacs — Getting started, File Explorer, Code Completion, Magit, Markdown
  - 🖥️ Terminals — Ghostty, Tmux, Alacritty, Kitty, WezTerm
  - 🪟 Hyprland — Keybindings (SUPERKEY notation) and Window Rules
  - 📂 Yazi — Keymap (navigation, selection, search, tabs, modes)

---

## ✨ **Recent Changes** (October 2025)

## 📅 10-25-25

- Added
  - Panels: Dark Material Shell (DMS) and Noctalia Shell are now selectable via
    `panelChoice` (per-host setting).
    - Hyprland startup updated to stop other bars and launch the chosen panel.
    - Noctalia is packaged as a QuickShell config; run with
      `qs -c noctalia-shell`.
  - MangoWC: integrated as an optional Home Manager module; enable with
    `enableMangowc = true;`.
  - Start menu: added zellij and nwg-menu entries to the custom start menu.
- Changed
  - Kernels: standardized on nixpkgs kernels; Cachy kernels removed from the
    stack.
- Removed
  - Filesystems: removed support for ZFS and bcachefs in this configuration.

## 📅 10-21-25

- v4l2loopback: re-enable using upstream kernel module on standard kernel
  - Add `boot.kernelModules = [ "v4l2loopback" ];`
  - Add
    `boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];`
  - Works with `pkgs.linuxPackages_latest`; no custom derivations or overlays
    needed
  - If device numbering/labels are desired, add module options via
    `boot.extraModprobeConfig`

## 📅 10-20-25

- Kernel: switch from CachyOS to standard NixOS latest kernel
  - Set `boot.kernelPackages = pkgs.linuxPackages_latest`
  - Removed Chaotic Nyx module import that provided CachyOS kernels/ZFS variants
  - Dropped ZFS package pin (`boot.zfs.package = pkgs.zfs_cachyos`) since ZFS is
    not in use
- v4l2loopback: remove custom build/overlays
  - Deleted GCC/clang workaround derivation and overlays that rebuilt the
    module/userspace
  - Removed `v4l2loopbackCtl` userspace tool from required packages
  - Result: eliminates frequent build failures during `flake` updates caused by
    out-of-tree rebuilds
- Files touched
  - `modules/core/boot.nix`: select linuxPackages_latest; removed
    ZFS/v4l2loopback custom build
  - `modules/core/default.nix`: removed `inputs.chaotic.nixosModules.default`
    and v4l2loopback overlays
  - `modules/core/req-packages.nix`: removed `v4l2loopbackCtl`
- Rationale
  - Not using ZFS; CachyOS + custom v4l2loopback rebuilds were brittle and often
    failed on channel bumps
  - Prefer upstream-supported kernel/modules for stability and simpler
    maintenance
- Action
  - Rebuild: `zcli rebuild` (or `nh os switch`) to apply the kernel change

## ✨ **Recent Changes** (September 2025)

## 📅 9-27-25

- Warp Terminal (current) packaging is now vendored inside ddubsOS for seamless
  updates
  - New local package: pkgs/warp-terminal-current/{package.nix, versions.json}
  - New local updaters: pkgs/warp-terminal-current/update.sh and warp-latest.sh
  - Overlay now consumes the vendored package; external flake input removed
  - Flake outputs expose packages.${system}.warp-terminal-current from the
    vendored package
  - zcli gained a new subcommand:
    - zcli update-warp [--commit]
      - Bumps to the latest upstream Warp release by following download
        redirects
      - Computes SRI hashes and updates versions.json
      - Optional --commit to auto-commit the bump
  - Module polish:
    - programs.warp-terminal-current.waylandSupport now defaults to true
    - Desktop entry now uses configurable Icon=${cfg.iconName} (default:
      warp-terminal-bld)
- Docs updated (EN/ES):
  - docs/zcli/zcli.md and docs/zcli/zcli.es.md now document zcli update-warp
  - modules/apps/warp-terminal-current.md updated to reflect vendored packaging
    and local update flow

## 📅 9-24-25

- ✅ **Waybar**:
- `Weather.py`
  - Fixed reliability issues, now uses OpenMeto
  - Updated weather condition icons to color
  - Created variables for location, metric, or imperial
- `waybar-jak-catppuccin.nix`
  - Fixed some styling, spacing issues
  - Rearranged the widgets for better balance
  - Made it default waybar in `default` host
- 🚀 **Proxmox BackupClient**:
  - Configure scripts to backup, list backups and restore
    - `pbs-home-backup`
    - `pbs-home-ls-all`
    - `pbs-home-restore-last`
    - `pbs-home-last`
    - `pbs-home-prune`
    - `pbs-home-show`
    - `pbs-home-ls`
    - `pbs-home-restore`
    - `pbs-home-verify`

## 📅 9-22-25

- 📚 qs-cheatsheets / 📚 qs-docs — Markdown rendering + search UX overhaul
  - ✅ Rendering fidelity: pre-convert Markdown → HTML using pandoc (GFM)
    - HTML artifacts written under:
      $TMPDIR/html/<category>/<language>/<file>.html
    - Fallback: if conversion fails, content is escaped and wrapped in <pre>
  - 🖼️ Viewer: switched QML content area to TextEdit.RichText
    - New property htmlContent preferred for display; falls back to escaped pre
      of markdown
    - Code blocks, tables, and lists now render correctly
  - 🔎 Search UX: removed inline <span> highlighting; added Matches side panel
    - Shows snippet per hit (~80 chars), click to jump
    - Approximate jump via contentY proportional to match start / file length
    - Prev/Next wired to jumpToMatch(index)
  - 🧩 QML model/properties: htmlContent, matchesModel; display prefers HTML
  - 🧰 Dependencies added: pandoc, jq, sed
  - 🛠️ Nix escaping fix: escape Bash parameter expansion as ''${...} inside Nix
    strings
  - 📝 Docs updated (EN/ES): detailed pipeline, viewer change, Matches panel,
    tips, and troubleshooting

## 📅 9-18-25

- Flake: Added NUR input and overlay; included nur.repos.charmbracelet.crush in
  global packages

## 📅 9-17-25

- 🛠️ **Suckless Package Refactor**: Modernized dwm, st, and slstatus build
  system
  - **Nix Integration**: Replaced manual `stdenv.mkDerivation` blocks with
    nixpkgs `overrideAttrs` approach
  - **Better Maintainability**: Now leverages battle-tested nixpkgs build logic
    and dependency management
  - **Preserved Customizations**: Maintains all custom source paths, patches,
    and static linking configurations
  - **Conditional Building**: Suckless tools only built when host has
    `dwmEnable = true` in variables.nix
  - **Architecture**:
    - `modules/home/suckless/pkgs.nix` - Uses `pkgs.dwm.overrideAttrs`,
      `pkgs.st.overrideAttrs`, `pkgs.slstatus.overrideAttrs`
    - `modules/home/default.nix:78` - Conditionally imports suckless module
      based on `dwmEnable`
    - `modules/home/suckless/dwm-session.nix` - System-level DWM service
      configuration
  - **Benefits**: Automatic dependency resolution, better error handling, easier
    maintenance when nixpkgs updates

- qs-keybinds: Window-manager modes and UI refinements
  - Added Niri, BSPWM, and DWM modes alongside existing
    Hyprland/Emacs/Kitty/WezTerm/Yazi modes
  - Split header into two rows:
    - Top row: window managers (Hyprland, Niri, BSPWM, DWM)
    - Second row: application views (Emacs, Kitty, WezTerm, Yazi, Cheatsheets)
  - Availability is host-dependent with detection and env overrides:
    - Buttons are hidden when the mode is unavailable on the host
    - Graceful fallback: when a mode is invoked but unavailable, the app shows
      an "unavailable mode" banner and renders an empty list instead of exiting
    - Optional env overrides for host state: QS_HAS_NIRI, QS_HAS_HYPR,
      QS_HAS_BSPWM, QS_HAS_DWM (0/1)
  - Hyprland integration:
    - Added window rules for "Niri Keybinds", "BSPWM Keybinds", and "DWM
      Keybinds" (float, center, no border/shadow, rounding, opacity) to match
      the rest of the qs-\* overlays
  - Layout: increased key column width and dynamic sizing to prevent long
    combinations (e.g., Mod+Ctrl+Shift+Wheel) from overlapping descriptions
  - Parsers:
    - Niri: new parser reads binds from ~/.config/niri/config.kdl
    - BSPWM: sxhkd parser reads ~/.config/sxhkd/sxhkdrc; handles blank/indented
      lines robustly
    - DWM: switched to sxhkd-based parser at ~/.config/suckless/sxhkd/sxhkdrc
    - Yazi: fixed submode case nesting; general shell case/esac fixes
  - Build/packaging fixes:
    - Escaped QS*HAS*\* env references in the Nix-generated script to avoid Nix
      evaluation errors
    - Corrected a missing quote in Hyprland window rules that caused a syntax
      error

## 📅 9-16-25

- 📚 **qs-docs**: New Qt6 QML documentation viewer for ~/ddubsos/docs/
  - **Smart documentation browsing**: Dedicated app for technical documentation
    with real-time search
  - **Multi-language support**: Supports both English and Spanish documentation
    files
  - **Intuitive interface**: Clean, modern UI matching the qs-cheatsheets design
  - **Keybinding**: `SUPER+SHIFT+D` launches qs-docs for quick access
  - **File organization**: Reads from `~/ddubsos/docs/` directory structure
  - **Search functionality**: Real-time filtering through documentation content
  - **Hyprland integration**: Window rules for floating and centering
  - **Technical documentation**: Comprehensive English and Spanish documentation
    included
    - Architecture details and file layouts
    - UI components and error handling
    - Performance considerations and maintenance
    - Future development plans

- 🔧 **qs-keybinds**: Fixed critical QML syntax errors preventing app launch
  - **Issue resolved**: Removed duplicate ListView components with conflicting
    IDs
  - **QML structure**: Fixed unclosed elements and malformed template hierarchy
  - **Full functionality**: All modes now work correctly (hyprland, emacs,
    kitty, wezterm, yazi, cheatsheets)
  - **Template generation**: Ensured proper heredoc generation without
    truncation
  - **Testing verified**: App launches and functions as expected across all
    configurations

- ⌨️ **Enhanced Quick-Select Keybinds**: Unified access to documentation and
  configuration tools
  - **SUPER+SHIFT+K**: Launch qs-keybinds (keybindings viewer)
  - **SUPER+SHIFT+C**: Launch qs-cheatsheets (cheatsheets browser)
  - **SUPER+SHIFT+D**: Launch qs-docs (documentation viewer)
  - **Consistent interface**: All three apps share similar UI design and
    behavior
  - **Professional workflow**: Quick access to help, documentation, and
    configuration reference

- 🚀 **Warp Terminal**: Dual-version support with current build and stable
  versions
  - **Package integration**: Added `warp-terminal-current` from flake input with
    Wayland support enabled
  - **Current build wrapper**: Created `warp-bld` executable that wraps latest
    upstream version with runtime backend detection
  - **Environment handling**: Automatically selects Wayland or X11 backend based
    on `XDG_SESSION_TYPE`
  - **Version checker**: New `warp-check` script compares stable vs current
    build versions and displays status
  - **Desktop entries**: Separate GUI launchers for stable ("Warp") and current
    build ("Warp (Current bld)")
  - **Cross-platform**: Works on both AMD and Intel GPU systems with Hyprland
  - **Runtime libraries**: Fixed Wayland connection panics by including required
    libraries in package build
  - **System activation**: Added desktop database and icon cache updates for
    proper menu integration
  - **Available commands**:
    - `warp-terminal` - stable version from nixpkgs
    - `warp-bld` - current upstream build with automatic backend selection
    - `warp-check` - version comparison and system status utility

## 📅 9-15-25

- 🔓 **qs-wlogout**: New compact Qt6 QML power menu implementation
  - **Compact design**: Small, centered floating window (520x320px) without huge
    blur frames
  - **Six power options**: Lock, Logout, Suspend, Hibernate, Shutdown, Reboot in
    3x2 grid
  - **Proper Hyprland integration**: Uses `hyprctl dispatch exit` for clean
    logout to SDDM
  - **Semi-transparent styling**: Blur-compatible background with rounded
    corners (20px radius)
  - **Keyboard shortcuts**: L, E, U, H, S, R keys for quick access; Escape to
    close
  - **Click-to-close**: Click anywhere on menu background to dismiss
  - **Window rules**: Hyprland rules for floating, centering, and visual effects
  - **Visual improvements**: Eliminated large shadow/blur boxes around menu area
  - **Qt6 QML runtime**: Uses standard Qt6 components instead of
    quickshell-specific ones
  - **Icon support**: 64x64 PNG icons for each power action with fallback
    generation
  - **🇪🇸 Spanish language support**: Use `-es` flag or `QS_WLOGOUT_SPANISH=1`
    for Spanish text
    - **Spanish translations**: Bloquear, Cerrar Sesión, Suspender, Hibernar,
      Apagar, Reiniciar
    - **Usage examples**:
      - `qs-wlogout -es` (Spanish mode)
      - `qs-wlogout` (English default)
      - `QS_WLOGOUT_SPANISH=1 qs-wlogout` (Environment variable)
    - **Hyprland integration**: Modify binding to default to Spanish mode
      - **Current binding**: `"ALT SHIFT,Q,exec, qs-wlogout"` in
        `modules/home/hyprland/binds.nix:68`
      - **For Spanish default**: Change to `"ALT SHIFT,Q,exec, qs-wlogout -es"`
      - **Alternative method**: Set environment variable in binding:
        `"ALT SHIFT,Q,exec, QS_WLOGOUT_SPANISH=1 qs-wlogout"`

## 📅 9-10-25

- ZCLI v1.1.0 — Interactive staging before rebuild/update
  - New pre-build flow: lists untracked/unstaged files with indices; choose
    numbers or 'all' to stage, or press Enter to skip.
  - New flags: `--no-stage` (skip prompt), `--stage-all` (stage everything
    automatically)
  - New command: `zcli stage [--all]` to run the staging selector without
    rebuilding
  - Deterministic git path pinned in dispatcher (GIT_BIN)
  - Help and docs updated (docs/zcli.md, docs/zcli.es.md)

- 🆕 Wallpapers: Restore on login with fallbacks and Hyprpanel-safe startup
  - New script: `qs-wallpapers-restore` restores the last selected wallpaper at
    session start
    - Reads state written by `qs-wallpapers-apply`:
      - `$XDG_STATE_HOME/qs-wallpapers/current.json` (path, backend, timestamp)
      - `$XDG_STATE_HOME/qs-wallpapers/current_wallpaper` (plain text path)
    - Preferred order: recorded backend → `swww` → `hyprpaper` → `mpvpaper` →
      `waypaper`
    - Hyprpanel safety: waits up to `QS_RESTORE_WAIT_HYPRPANEL_SECONDS` (default
      15s) for `hyprpanel` before starting `swww-daemon`; if `waybar` is already
      running, proceeds immediately
    - Stops conflicting daemons between attempts (e.g., stop mpvpaper/hyprpaper
      before swww; stop swww/hyprpaper before mpvpaper)
    - Override order via `QS_RESTORE_ORDER` (comma-separated)
  - Apply script enhancement: `qs-wallpapers-apply` now persists the selection
    to the state files above
  - Hyprland integration: `modules/home/hyprland/exec-once.nix` now calls
    `qs-wallpapers-restore`
    - Hyprpanel branch: `hyprpanel` then `qs-wallpapers-restore`, with fallback
      to default `stylixImage` via `waypaper --backend swaybg`
    - Waybar branch: starts `swww-daemon`/`waybar`, then `qs-wallpapers-restore`
      with fallback to `stylixImage` via `waypaper --backend swww`
  - Packaging: added `qs-wallpapers-restore` to `home.packages` in
    `modules/home/scripts/default.nix`
  - Docs:
    - Updated: `docs/qs-wallpapers.md` (persistence + restore integration)
    - New: `docs/qs-wallpaper-restore.md` (behavior, env vars, exit semantics)

## 📅 9-09-25

- Power management: Hard-block suspend/hibernate on Nvidia hybrid systems
  - Profiles: applies only to `nvidia` and `nvidia-laptop`
  - Rationale: hybrid Nvidia laptops often fail to resume reliably; masking the
    systemd sleep targets prevents involuntary suspend/hibernate regardless of
    source (logind, DE, timers, etc.)
  - Implementation (modules/core/services.nix):

```nix
system.activationScripts.ddubsosMaskSleepTargets = lib.mkIf (profile == "nvidia" || profile == "nvidia-laptop") {
  text = ''
    for u in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
      systemctl mask "$u" || true
    done
  '';
};

# Ensure they are unmasked on non-Nvidia profiles (in case of profile switches)
system.activationScripts.ddubsosUnmaskSleepTargets = lib.mkIf (!(profile == "nvidia" || profile == "nvidia-laptop")) {
  text = ''
    for u in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
      systemctl unmask "$u" || true
    done
  '';
};
```

- Rebuild: `zcli rebuild` (or `nixos-rebuild switch --flake .#<profile>`) and
  verify:
  - `systemctl --no-pager status sleep.target suspend.target hybrid-sleep.target hibernate.target`

- Fix: Correct systemd-logind lid switch keys so overrides take effect
  - Previous typo used `HandlelidSwitch`/`HandlelidSwitchDocked` (lowercase
    "l"); systemd ignored the entries.
  - Now correctly capitalized in services.nix:

```nix
services.logind.settings.Login = {
  HandleLidSwitch = "ignore";
  HandleLidSwitchDocked = "ignore";
};
```

## 📅 9-06-25

- Overlays: Introduced a nixpkgs overlay that exposes three flake inputs as
  pkgs:
  - pkgs.hyprpanel
  - pkgs.ags
  - pkgs.wfetch Rationale: Keep NixOS/Home Manager modules decoupled from inputs
    and consume packages only via pkgs.

- Refactor: modules/core/req-packages.nix now consumes these from pkgs instead
  of inputs.\*.packages.${system}.default.

- Docs: Updated docs/project-guide.md and docs/project-guide.es.md to document
  the overlay approach and note that future external packages (e.g., quickshell)
  should be surfaced via the overlay and then referenced from pkgs.

## 📅 9-05-25

- Kernel: continue using CachyOS kernels to maintain working ZFS
  (pkgs.linuxPackages_cachyos + zfs_cachyos)
- v4l2loopback with Cachy kernel (clang-built) fixes
  - Problem: building v4l2loopback against a clang-built Cachy kernel fails when
    Kbuild invokes gcc or when clang is wrapped with incompatible flags.
  - Symptoms seen during nixos-rebuild:
    - gcc: command not found (Kbuild defaulting to gcc)
    - gcc: unrecognized options (-mretpoline-external-thunk, -fsplit-lto-unit)
    - clang: unused-command-line-argument errors
    - After fixing compile: installPhase tries to install userspace utility
      (utils/v4l2loopback-ctl) and fails due to missing libc headers
    - Harmless warnings: missing System.map (depmod skipped), BTF skipped (no
      vmlinux), DKMS signing notices
  - Resolution applied in modules/core/boot.nix:
    - Build with LLVM toolchain and unwrapped clang/lld
      - stdenv = pkgs.llvmPackages.stdenv
      - CC/LD/LLVM exported; makeFlags: LLVM=1 CC=clang LD=ld.lld
      - Use clang-unwrapped to avoid nix cc-wrapper multi-target warnings
      - EXTRA_CFLAGS adds -Wno-…unused-command-line-argument to silence kernel
        CFLAGS under clang
    - Skip userspace utils entirely (OBS only needs the kernel module)
      - Drop -bin output; outputs = [ "out" ]
      - Override installPhase to run only modules_install for the .ko
      - Disable upstream postInstall
  - Result: v4l2loopback.ko builds and installs cleanly with the Cachy kernel;
    the rebuild proceeds past the module stage. Final verification pending.
  - Notes:
    - System.map/BTF warnings are expected in Nix module builds; depmod runs
      later in activation/boot.
    - DKMS signing messages are informational; kernel sign-file is invoked with
      the kernel’s signing key.

- 🖼️ Rofi Wallpaper Picker (thumbnails + cache)
  - New script: `rofi-wallpapers` scans `~/Pictures/Wallpapers` for images
    (follows symlinks), excludes videos, builds a thumbnail grid, and prints the
    selected file
  - New script: `rofi-wallpapers-apply` launches the picker and applies the
    selection via `swww img`
  - New script: `wallpaper-thumbs-build` pre-generates a thumbnail cache
    (ImageMagick) for fast rendering
  - Home Manager activation: prebuilds the wallpaper thumbnail cache at rebuild
    time (default size: 200px)
  - UI/Theme: dedicated Rofi theme at `~/.config/rofi/wallpapers.rasi` (colors
    inherit from `menu.config.rasi`)
    - Default grid: 5 x 3, large thumbnails, filename centered below, rounded
      corners, transparent tiles, scrollbar enabled
    - Tight gutters and minimal padding for an image-first layout on 1080p
  - Hyprland integration:
    - Keybind: SUPER+SHIFT+W now opens the wallpaper picker and applies the
      selection
    - Window rule: per-window rounding for Rofi via `windowrulev2` (blur and
      shadows remain globally enabled)
  - Configurability:
    - Grid and size can be overridden: `WALL_COLS`, `WALL_ROWS`,
      `WALL_THUMB_SIZE`, `WALL_DIR`, `WALL_CACHE_DIR` or via `-c`, `-r`, `-s`,
      `-d`, `-t` flags
  - Implementation notes:
    - Uses a stable hash of the source path for cache keys
    - Supports Home Manager symlinked wallpapers (find -L)

## 📅 9-04-25

- Retored ddubsOS v1 rofi menu and waybar

## 📅 9-01-25

- 🛠️ Disabled `F1` help in NeoVIM for most modes `leader h` to access it
- 🚀 ZCLI: `zcli settings` or `zcli features` shows current configuration
  - The hosts `variables.nix` file is parsed
  - Showing GUIs enabled, defaul terminal, browser
  - Editors, NFS, devenv, etc.
  - Future update will allow enable/disable of theses features
  - `zcli upgrade` is now an alias for `zcli update`
- 🧰 Waybar: Standardized app menu across all Waybar profiles
  - Left-most module now includes a NixOS icon () that launches the default
    application menu via: rofi -show drun
  - Added tooltip: "App menu"
  - Replaced any use of nwg-drawer with rofi to ensure availability and
    consistency
- 🖥️ Displays/Monitors (formatting/docs update, not a new feature): Migrated
  guidance to Hyprland monitorv2
  - hosts/\*/variables.nix: moved monitor settings to the bottom; commented
    legacy `monitor =` lines; added equivalent `hyprMonitorsV2` blocks; default
    VM provides `Virtual-1` in v2 and legacy (commented)
  - hosts/default/variables.nix: consolidated all monitor examples at the
    bottom; added transform mapping and enabled flags
  - FAQ (EN/ES): updated monitor sections to monitorv2 with examples; legacy
    notes retained
  - Docs: added multiple-monitor examples and transform values; clarified
    mirroring and enable/disable semantics
- ⚠️ Known issue: nwg-displays and nwg-drawer currently unavailable in nixpkgs
  - Cause: Python build/test breakages (e.g., i3ipc/pytest failures under Python
    3.13)
  - https://github.com/nixos/nixpkgs/issues/437058
  - Fix being tracked: https://github.com/NixOS/nixpkgs/pull/438729
  - Action: Using rofi as the fallback app launcher; will re-enable nwg-\* tools
    when upstream issues are resolved

## ✨ **Recent Changes** (August 2025)

## 📅 8-31-25

- 📊 Waybar: Added new module `waybar-tony.nix` inspired by @tony,btw
  - Source: https://www.github.com/tonybanters/hyprland-btw
  - Config/style imported from local JSONC and CSS; translated into a Nix Home
    Manager module
  - Added commented `waybarChoice` entry to `hosts/*/variables.nix` for easy
    enablement
  - Set the new waybar as the default after adding additional widgets
- 🛠️ fix(polybar): prevent Polybar from starting under Hyprland sessions
  - Context: When bspwm and Waybar are enabled for hosts/ddubsos-vm but logging
    into Hyprland, Polybar was also starting (dual bars)
  - Change 1: Removed manual `polybar &` from bspwm autostart
    (modules/home/gui/bspwm/bspwm.nix)
  - Change 2: Gated Polybar systemd user service to bspwm on X11 only via Unit
    conditions
    - XDG_SESSION_TYPE=x11
    - XDG_SESSION_DESKTOP=bspwm
  - Result: Polybar only starts with bspwm; Hyprland sessions use Waybar without
    Polybar
- 🛠️ fix(zcli/doom): robust Doom Emacs detection for status/update
  - Locate `doom` via PATH first, then `~/.emacs.d/bin/doom`, then
    `~/.config/emacs/bin/doom`
  - Validate install by checking `core/doom.el` in the resolved Doom directory
  - Use the located `doom` binary for `version` and `sync` to prevent false
    negatives
- 🛠️ fix(macbook): permit Broadcom STA 6.12.44 to unbreak rebuild
  - Context: nixpkgs bumped `broadcom-sta` from `…6.12.43` to `…6.12.44`. Our
    macbook host allowed only the previous exact string, causing evaluation
    failure on rebuild.
  - Error:
    `Package ‘broadcom-sta-6.30.223.271-57-6.12.44’ is marked as insecure, refusing to evaluate.`
  - Change: Updated `hosts/macbook/default.nix`
    `nixpkgs.config.permittedInsecurePackages` to include
    `"broadcom-sta-6.30.223.271-57-6.12.44"`.
  - Result: `zcli rebuild` evaluates and builds successfully for host `macbook`
    on profile `intel`.
  - Future: Consider a small overlay/module to compute the exact permitted name
    dynamically from `pkgs.broadcom-sta.version` to avoid manual bumps on future
    nixpkgs updates.

## 📅 8-30-25

- Themed `micro` in `andromeda` theme for NatePick.
- `modules/home/editors/micro-andromeda.nix`
- I themed it `catppuccin` in `modules/home/editors/micro.nix`
- Created variable `enableMicro` in `hosts/default/variables.nix` to enable it

## 📅 8-29-25

- 🔧 **Flake**: Deduplicated `nixosConfigurations` using `mkNixosConfig` helper
  function to reduce repetition while preserving GPU-type based profiles and
  `nixos-rebuild` compatibility.
- 🧹 **Flake**: Removed unused `nixpkgs-stable` input; Audacity builds from
  primary channel
  - Scan: no active references to `inputs.nixpkgs-stable` (only a commented
    example in modules/core/req-packages.nix from late July 2025)
  - Change: deleted `nixpkgs-stable` from inputs to reduce lockfile churn and
    evaluation surface
  - Rationale: Audacity no longer needs pinning; if a package requires stable in
    the future, reintroduce `nixpkgs-stable` and expose `pkgsStable` selectively
    via `specialArgs`

### 📅 8-28-25

- 📹 v4l2loopback kernel module: fixed build failure on CachyOS kernel by
  building only the kernel module and skipping utils
  - Added overlay to the ddubsOS module stack that overrides v4l2loopback for
    both linuxPackages and linuxPackages_cachyos
  - Build: make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
    M=$PWD modules
  - Install: make ... modules_install INSTALL_MOD_PATH=$out
  - Skips building userspace utils (v4l2loopback-ctl) which require glibc and
    caused linker errors (crt1.o, crti.o, -lgcc_s) in the kernel build env
  - If you need v4l2loopback-ctl, install a separate userspace package (when
    available) in environment.systemPackages
- 🛠️ v4l2loopback-ctl userspace tool: add standalone package and fix derivation
  - New package: pkgs.v4l2loopbackCtl builds utils/v4l2loopback-ctl in userland
    and is added to system packages
  - Reuses v4l2loopback src from linuxPackages_cachyos (or linuxPackages as
    fallback)
  - Fixed rebuild error (attribute 'name' missing) by setting version in the
    derivation (pname + version)
  - Result: module builds via kernel tree; ctl tool is available on PATH and
    links against glibc normally

### 📅 9-06-25

- Hyprland + AGS v1 coexistence: introduce agsv1 wrapper and update SUPER+A
  - What changed
    - Added an overlay wrapper package agsv1 that invokes the pinned AGS v1
      binary (inputs.ags ref = "v1") at /bin/agsv1
    - Included agsv1 in system packages so it’s available on PATH
    - Updated Hyprland binding SUPER + A to launch agsv1 -t 'overview' instead
      of ags
  - Why
    - Preserve the existing Overview app that depends on AGS v1 while enabling
      side-by-side testing of newer AGS (v3/v4)
  - How to run
    - Overview: uses agsv1 explicitly via the Hyprland binding and can be run
      manually with agsv1
    - Newer AGS (future): install a separate AGS package that provides /bin/ags
      and run it as ags; it will not interfere with agsv1
  - How to add newer AGS alongside v1 (example options)
    - Option A (separate input): add inputs.ags-next = { owner = "aylur"; repo =
      "ags"; ref = "v3"; }; expose as pkgs.ags-next via overlay; install
      alongside agsv1
    - Option B (bump inputs.ags): update inputs.ags to v3/v4 while keeping agsv1
      wrapper pointing at the old v1 input; continue using agsv1 for the
      Overview
  - Files touched
    - modules/core/overlays.nix — adds agsv1 wrapper
    - modules/core/req-packages.nix — adds agsv1 to environment.systemPackages
    - modules/home/hyprland/binds.nix — binds SUPER + A to agsv1 -t 'overview'

### 📅 8-27-25

- 🪐 COSMIC Desktop integration (Alpha): Added `cosmicEnable` toggle (default:
  false), system-level enablement via `services.desktopManager.cosmic.enable`,
  Home Manager module with COSMIC apps (`modules/home/gui/cosmic-de.nix`), and
  docs updates. Note: COSMIC DE is Alpha; expect rapid changes and occasional
  breakage.

### 📅 8-26-25

- 🔧 Fix infinite recursion in boot mirror installers: Removed circular
  dependencies in nix-iso scripts
  - Fixed `scripts/install-zfs-boot-mirror.sh` and
    `scripts/install-btrfs-boot-mirror.sh`
  - Removed problematic `{ pkgs, lib, options, ... }:` pattern that accessed
    `options` during module evaluation
  - Commented out `mirroredBoots` configuration with clear instructions for
    manual enablement
  - Prevents `error: infinite recursion encountered` during NixOS installation

- 🔑 Complete binary cache configuration: Fixed missing trusted public keys
  causing substitute warnings
  - Added missing `cache.nixos.org-1` trusted public key to both `flake.nix`
    nixConfig and `modules/nix-caches.nix`
  - Updated `install-ddubsos.sh` to use
    `--option accept-flake-config true --refresh` flags on initial build
  - Eliminates warnings:
    `ignoring substitute for '/nix/store/...' from 'https://nyx.chaotic.cx', as it's not signed by any of the keys in 'trusted-public-keys'`
  - Ensures all configured caches (NixOS, nix-community, Chaotic) are properly
    trusted from first build
  - Prevents unnecessary kernel compilation by using pre-built CachyOS packages
    from Chaotic cache
  - Improves build performance by enabling use of pre-built packages from all
    cache sources

- 🧩 Installer robustness: hardware.nix detection works for bcachefs and ext4
  - Fixed false negatives: "root device missing/empty" when using a standard
    /etc/nixos/hardware-configuration.nix
  - ensure_module_wrapper now inspects the first non-empty, non-comment line; no
    longer wraps valid modules that start with comments
  - extract_root_device made robust; supports both dotted (fileSystems."/" = {
    ... }) and nested (fileSystems = { "/" = { ... }; }) syntaxes
  - --regen-hw now behaves correctly across common filesystems (ext4, bcachefs,
    zfs) and VM guests (qemu-guest profile)
  - Prevents installer aborts on healthy configurations generated by
    nixos-generate-config

- Installer (install-ddubsos.sh): Prefer the system's
  /etc/nixos/hardware-configuration.nix for hardware detection, with validation
  and safe fallback.
  - Validate that hardware.nix has no empty device strings, includes a
    fileSystems attrset, and that referenced /dev/disk/by-uuid symlinks exist.
  - Warn (don't fail) if the configured root device doesn't match the currently
    mounted root; continue.
  - If validation fails or the system file is missing, generate a minimal
    hardware module without fileSystems (nixos-generate-config
    --no-filesystems), falling back to filtering out fileSystems from
    --show-hardware-config.
  - Rationale: Avoids broken empty device entries on bcachefs or live/overlay
    contexts, while remaining filesystem-agnostic. ddubsOS assumes NixOS is
    already installed; disk/filesystem setup is handled externally (e.g.,
    nix-iso).

- 🌐 Docs i18n: Spanish translations and language switches for top-level docs
  - Created README.es.md, CODE_OF_CONDUCT.es.md, CONTRIBUTING.es.md,
    LICENSE.es.md (unofficial)
  - Inserted language switches into English originals (README.md,
    CODE_OF_CONDUCT.md, CONTRIBUTING.md, LICENSE.md)
  - Scope limited to repository root; excluded FAQ.md and CHANGELOG.ddubs.md

#### 📅 **8-25-25**

- 🚀 Install Script: Conditional repo detection; preserve curl flow; no re-clone
  from repo
  - Behavior
    - If run from a cloned repo (script directory contains .git and flake.nix):
      reuse the current repo
    - If ~/ddubsos exists and is a git repo: reuse it
    - If no repo present (curl | bash): clone to ~/ddubsos then proceed
  - Changes
    - Removed backup/move of existing ~/ddubsos to ~/.config/ddubsos-backups
    - Removed unconditional git clone + cd to ~/ddubsos
    - Ensure working directory is the chosen repo; nixos-rebuild uses
      .#${profile}
  - Why
    - Avoids destructive file moves and redundant clones; keeps curl install
      path working

- 🧬 Kernel/Filesystem Stack: Move to CachyOS kernel with matching ZFS package
  via Chaotic Nyx
  - ✅ What changed
    - Set `boot.kernelPackages = pkgs.linuxPackages_cachyos`
    - Set `boot.zfs.package = pkgs.zfs_cachyos`
    - Imported Chaotic Nyx module for access to CachyOS kernel/ZFS variants:
      `inputs.chaotic.nixosModules.default`
    - Files updated:
      - `modules/core/default.nix` (imports Chaotic Nyx module)
      - `modules/core/boot.nix` (selects CachyOS kernel and ZFS package)
  - 🎯 Why
    - Avoids enabling `nixpkgs.config.allowBroken` for ZFS installs on newer
      kernels
    - Ensures kernel/ZFS ABI compatibility (fewer build/eval failures)
    - Leverages Chaotic Nyx caches for fast builds (when binary caches are
      configured)
  - 🧩 Scope/Compatibility
    - Works with our GPT + systemd-boot + UEFI baseline
    - Safe for non-ZFS systems (just selects a kernel flavor); ZFS gets a
      matching userland
  - 🔧 Overrides (if needed)
    - You can override per-host with `boot.kernelPackages` or `boot.zfs.package`
      in a host’s `hardware.nix` or module

- 🧰 Temporary package adjustments after flake update (Python 3.13 test
  breakages)
  - Context
    - A flake update pulled newer nixpkgs where Python 3.13 + pytest caused
      upstream package tests to fail.
    - Notably:
      - pygls (via cmake-language-server) failed import-time checks (lsprotocol
        API mismatch).
      - i3ipc (pulled by nwg-\* apps) failed async pytest suites, e.g. "Failed:
        async def functions are not natively supported."
  - Actions taken
    - Commented out cmake-language-server in editors module (evil-helix).
    - Disabled all nwg-\* applications except nwg-dock-hyprland (kept enabled).
    - Overlays to skip upstream tests were attempted but removed; will re-enable
      packages once upstream fixes land.
  - Plan
    - Monitor nixpkgs updates; re-enable cmake-language-server and nwg-\* once
      fixed.

#### 📅 **8-24-25**

- Context
  - A flake update pulled newer nixpkgs where Python 3.13 + pytest stack caused
    upstream package tests to fail.
  - Notably:
    - pygls (via cmake-language-server chain) failed import-time checks
      (lsprotocol API mismatch).
    - i3ipc (pulled by nwg-\* apps) failed async pytest suites with errors like:
      - "Failed: async def functions are not natively supported."
      - PytestRemovedIn9 warnings about async fixtures and BrokenPipeError
        during tests.
- Actions taken
  - Commented out cmake-language-server in editors module (evil-helix).
  - Disabled all nwg-\* applications EXCEPT nwg-dock-hyprland (kept enabled).
  - Attempted overlays to skip upstream tests (pygls/i3ipc) but removed to avoid
    complexity—will re-enable packages once upstream is fixed.
- Plan
  - Monitor nixpkgs updates; re-enable cmake-language-server and nwg-\* apps
    (nwg-displays, nwg-panel, etc.) when the upstream Python packages are fixed.
  - Keep Warp and other desired updates from the newer nixpkgs while avoiding
    the failing packages for now.

#### 📅 **8-24-25**

- 🚀 Build Performance: Configure binary caches globally to avoid local
  kernel/ZFS compiles
  - 🔧 Flake-level nixConfig: added extra-substituters and
    extra-trusted-public-keys so consumers of the flake automatically see caches
    (when accept-flake-config is honored)
    - Substituters: https://nix-community.cachix.org, https://nyx.chaotic.cx/
    - Keys: nix-community and nyx public keys
  - 🧩 NixOS module (modules/nix-caches.nix): sets nix.settings to enforce
    daemon-level trust
    - experimental-features = [ "nix-command" "flakes" ]
    - accept-flake-config = true
    - substituters = cache.nixos.org, nix-community, nyx
    - trusted-public-keys = matching keys for the above caches
  - 🖇️ Imported the module into all profiles (amd, intel, nvidia, nvidia-laptop,
    vm)
  - ✅ Result: Host pulls prebuilt binaries from caches by default; faster
    ISO/system builds, fewer source compiles
  - ℹ️ Note: Flake-level settings are advisory; daemon-level nix.settings
    ensures consistent use of caches across all Nix commands

#### 📅 **8-22-25**

- ✍️ Emacs — Changed `emacs-pgtk` to `emacs-gtk` To support Wayland and X11
- 🖥️ Shell — Fastfetch scripts, `ff`, `ff1`, `ff2` now report shell correctly
  - Alias for zoxide `zi` for legacy users `cdi` is default with nix integration
    of zoxide

#### 📅 **8-21-25**

- 📚 **Cheatsheets Library**: Added centralized, human-friendly docs under
  `cheatsheets/`
  - 🔗 Quick Links and directory tree in `cheatsheets/README.md`
  - 🧩 Topics added:
    - ✍️ Emacs — Getting started, File Explorer, Code Completion, Magit,
      Markdown
    - 🖥️ Terminals — Ghostty, Tmux, Alacritty, Kitty, WezTerm
    - 🪟 Hyprland — Keybindings (SUPERKEY notation) and Window Rules
    - 📂 Yazi — Keymap (navigation, selection, search, tabs, modes)

#### 📅 **8-20-25**

- ✅ **Major Feature Release**: Added comprehensive Development Environment
  Module to New Features Spotlight section
- 🎞️ **Hyprland Animations**: Resolved Hyprtrails blue blob on window close
  - 🛠️ Introduced `animations-end-slide.nix` (slide-based window close) to avoid
    the `popin` scale conflict with Hyprtrails
  - 🔁 Updated host variables to use the new animation where
    `animations-end4.nix` was active; added a commented option on hosts using
    other animations
  - 🎯 Result: Hyprtrails tail renders cleanly on window close with no
    center-screen blue blob/flicker
  - 📁 Files updated: `hosts/*/variables.nix` (per-host `animChoice`) — new
    animation file located at `modules/home/hyprland/animations-end-slide.nix`

#### 📅 **8-19-25**

- 📝 **Note Management**: Added comprehensive `note` script for timestamped
  note-taking
  - ✨ **Simple Notes**: `note call plumber tomorrow` - Creates timestamped
    notes with auto-numbering
  - 📄 **Multi-line Support**: `cat file.txt | note` or
    `echo -e "line1\nline2" | note` - Preserves line breaks and formatting
  - 🎨 **Colorful Display**: Beautiful color-coded output with emojis and visual
    separators
  - 👀 **View Notes**: `note` - Displays all notes with timestamps and content
    formatting
  - 🗑️ **Delete Notes**: `note del 3` - Remove specific notes by number with
    validation
  - 🧹 **Clear All**: `note clear` - Remove all notes with confirmation prompt
  - ❓ **Help System**: `note help` - Comprehensive usage documentation
  - 💾 **File Storage**: Notes stored in `~/notes.txt` with structured format
  - 🎯 **Smart Numbering**: Automatic incremental note IDs with gap handling
  - 🛡️ **Error Handling**: Robust input validation and user-friendly error
    messages

- 📚 **Documentation**: Updated `zcli.md` and `FAQ.md` with comprehensive zcli
  v1.0.3 feature documentation
  - 🔥 **Doom Emacs Management**: Added complete documentation for `doom`
    commands:
    - 🚀 `doom install` - Automated Doom Emacs installation with get-doom script
    - ✅ `doom status` - Installation status checking with version information
    - 🗑️ `doom remove` - Complete removal with safety warnings
    - 🔄 `doom update` - Package and configuration updates via doom sync
  - 📊 **Glances Server Management**: Added comprehensive documentation for
    Docker-based monitoring:
    - 🌐 `glances start/stop/restart` - Service lifecycle management
    - 📈 `glances status` - Status reporting with access URLs (port 61210)
    - 📝 `glances logs` - Container log viewing for troubleshooting
    - 🛠️ Requires `glances-server.nix` module enablement
  - ⚙️ **Advanced Build Options**: Documented all optional parameters for
    rebuild commands:
    - 🔍 `--dry, -n` - Preview mode showing planned changes without execution
    - ❓ `--ask, -a` - Interactive confirmation prompts for safety
    - 💻 `--cores N` - CPU core limiting for VMs and resource management
    - 📋 `--verbose, -v` - Detailed operation logging and output
    - 🎯 `--no-nom` - Disable nix-output-monitor for traditional output
  - 🔄 **Project Branding**: Updated all references from ZaneyOS to ddubsOS
    v1.0.3
  - 🛠️ **Command Reference**: Added doom (🔥) and glances (📊) to command tables
  - 📁 **Path Corrections**: Fixed remaining `~/zaneyos` to `~/ddubsos` path
    references
  - ✨ **Usage Examples**: Added practical command combinations and use cases

#### 📅 **8-17-25**

- 🖥️ **Terminal Module Variables**: Implemented conditional terminal loading
  system
  - 📦 **Module Architecture**: Added boolean variables for selective terminal
    enablement (`enableAlacritty`, `enableTmux`, `enablePtyxis`)
  - 🔧 **Conditional Imports**: Modified `modules/home/default.nix` to use
    conditional imports based on host variables
  - 🎯 **Host Configuration**: Added terminal variables to all 11 host
    configurations with `false` defaults
  - ⚡ **Build Optimization**: Reduces system build time and disk usage by
    excluding unused terminal packages
  - 🗂️ **Module Restructure**: Moved conditional terminals out of
    `terminals/default.nix` to conditional loading
  - 🛡️ **Core Terminals**: Kept essential terminals (foot, kitty, ghostty,
    wezterm) as always-loaded
  - ✅ **Testing**: Validated flake evaluation with conditional loading and
    mixed terminal states
  - 📝 **Clean Architecture**: Maintains existing settings while adding new
    optional terminal features

- 🖼️ **Wallpaper Fallback Fix**: Implemented robust default wallpaper fallback
  mechanism for Hyprland environments
  - 🔧 **Issue Resolution**: Fixed problem where no default wallpaper was set on
    fresh installations causing blank desktop
  - 🛠️ **Fallback Strategy**: Modified `exec-once.nix` to include fallback when
    `waypaper --restore` fails
  - 🎯 **Backend Selection**: Uses `swaybg` backend for hyprpanel (simple,
    daemonless) and `swww` backend for other panels
  - 📦 **Package Addition**: Added `swaybg` to `modules/core/req-packages.nix`
    for system-wide availability
  - ✅ **Testing**: Validated fallback mechanism works reliably across different
    panel configurations
  - 📝 **Robust Implementation**: Ensures wallpaper is always set even on first
    boot or missing waypaper history

- 🏗️ **Editor Module Variables**: Implemented conditional editor loading system
  - 📦 **Module Architecture**: Added boolean variables for selective editor
    enablement (`enableEvilhelix`, `enableVscode`)
  - 🔧 **Conditional Imports**: Modified `modules/home/default.nix` to use
    conditional imports based on host variables
  - 🎯 **Host Configuration**: Added editor variables to all 11 host
    configurations with `false` defaults
  - ⚡ **Build Optimization**: Reduces system build time and disk usage by
    excluding unused editor packages
  - 🗂️ **Module Mapping**: Variables control import of `editors/evil-helix.nix`
    and `editors/vscode.nix` modules
  - ✅ **Testing**: Validated flake evaluation with conditional loading and
    mixed editor states
  - 📝 **Documentation**: Updated FAQ.md with configuration instructions and
    usage examples

- 🏗️ **Desktop Environment Variables**: Implemented conditional desktop
  environment loading system
  - 📦 **Module Architecture**: Added boolean variables for selective DE
    enablement (`gnomeEnable`, `bspwmEnable`, `dwmEnable`, `wayfireEnable`)
  - 🔧 **Conditional Imports**: Modified `modules/home/default.nix` to use
    conditional imports based on host variables
  - 🎯 **Host Configuration**: Added DE variables to all 10 host configurations
    with `false` defaults
  - ⚡ **Build Optimization**: Reduces system build time and disk usage by
    excluding unused desktop environment packages
  - 🔄 **Install Script Compatibility**: Verified existing sed patterns in
    `install-ddubsos.sh` remain functional
  - 🗂️ **Module Mapping**: `dwmEnable` → `suckless/default.nix`, others map to
    respective `gui/*.nix` modules
  - ✅ **Testing**: Validated flake evaluation with conditional loading and
    mixed DE states

- 🔧 **Glances Server**: Enhanced configuration with conditional enablement
  - 🛠️ **Conditional Startup**: Added `enableGlances` variable for host-specific
    control
  - ⚙️ **Disabled by Default**: Glances server disabled by default, can be
    enabled per-host
  - 📊 **Consistent Settings**: Maintains `refresh=2` setting with improved
    configuration

- 📝 **Doom Emacs**: Enhanced editor functionality
  - 🔤 **Hunspell Integration**: Modern spell checker with multi-language
    support
  - 🌍 **Multi-Language Dictionaries**: US English, Australian English, and
    Spanish
  - ⚙️ **Automatic Configuration**: Proper hunspell setup for seamless spell
    checking
  - ✨ **Flyspell Ready**: Real-time spell checking enabled in Doom Emacs
  - 🌲 **Treemacs**: Added file explorer sidebar (activate with `SPC o p`)

- 🛠️ **zcli v1.0.3**: Enhanced CLI utility with comprehensive argument parsing
  and improved help documentation
  - 🔧 **Advanced Options**: Added support for multiple command-line flags:
    - `--dry, -n` - Show what would be done without executing (dry run mode)
    - `--ask, -a` - Ask for confirmation before proceeding with operations
    - `--cores N` - Limit build operations to N CPU cores (useful for VMs)
    - `--verbose, -v` - Enable verbose output for detailed operation logs
    - `--no-nom` - Disable nix-output-monitor for cleaner output
  - 📚 **Enhanced Help**: Comprehensive help text with detailed option
    explanations
  - 🎯 **Smart Parsing**: Robust argument parsing with error handling and
    validation
  - 🔄 **Backward Compatible**: All existing `zcli` commands work unchanged
  - ✅ **Available Commands**: Enhanced argument support for `rebuild`,
    `rebuild-boot`, and `update`

- 🎛️ **Hyprland**: Implemented conditional panel choice configuration
  - 🚀 **Smart Panel Selection**: Added `panelChoice` variable to all host
    configurations
  - 🔧 **Conditional Startup**: Modified `exec-once.nix` to use conditional
    logic based on panel choice

#### 📅 **8-16-25**

- 🚀 **Install Script**: Major improvements to user experience and safety
  - ⚠️ **Hostname Warning**: Added critical warning against using 'default'
    hostname (prevents template overwrite)
  - 🏷️ **Better Hostname Default**: Changed from '[default]' to '[my-desktop]'
    with suggested alternatives
  - ⌨️ **Keyboard Layout Help**: Added comprehensive list of common layouts (us,
    uk, de, fr, dvorak, etc.)
  - 🗺️ **Smart Console Keymap**: Now defaults to match keyboard layout with
    helpful explanations
  - 📝 **Improved Git Config**: Added context explanations and better
    placeholder defaults
  - ✅ **Confirmation Messages**: Added confirmation for all user selections
  - 💡 **Visual Improvements**: Enhanced formatting with emojis, colors, and
    clear section headers
  - 🛡️ **Safety Features**: Prevents common user mistakes with better defaults
    and warnings

- 🔧 **NeoVIM**: Fixed nil LSP auto-import flakes configuration
  - ❌ **Issue**: "Some flake inputs are not available. Fetch them now" dialog
    appearing on every Nix file open
  - 🔍 **Root Cause**: Missing `auto_eval_inputs = true` configuration for nil
    LSP server
  - ✅ **Solution**: Added proper nil LSP configuration in `luaConfigPost`
    section
  - 🎯 **Result**: Nil LSP now automatically evaluates flake inputs without
    prompting
  - 📁 **Backup**: Added `.nil` project configuration file for additional
    reliability

- ✅ **Major Feature Release**: Added comprehensive OpenWebUI + Ollama AI
  Infrastructure to New Features Spotlight section

#### 📅 **9-13-25**

- 📝 Emacs/Doom refactor: standardize Emacs as a Home Manager feature
  - ✅ Enabled Emacs user daemon (services.emacs.enable) and set emacsclient as
    default editor (emacs-pgtk)
  - 🔄 Home Manager activation now bootstraps Doom on first run (git clone into
    ~/.emacs.d if empty) and runs `doom sync -u` on every activation
  - 🧹 Removed zcli Doom subcommands and the installer wiring; simplified zcli
    help
  - 📄 Docs updated (zcli.md/es, FAQ, project-guide EN/ES, getting-started
    cheatsheets) to reflect emacsclient usage and the new `et` terminal wrapper

- 🎨 Terminal Emacs (TTY) color/contrast improvements
  - 🌈 Truecolor pipeline: export COLORTERM=truecolor; prefer
    xterm-direct/tmux-direct when available via new `et` wrapper
  - 🖤 TTY faces: force dark background and set higher-contrast defaults;
    normalize bold to avoid brightening
  - 🔧 tmux: set default-terminal tmux-256color and keep RGB terminal-overrides
  - 🌓 Terminal configs: disable bold→bright mapping in Ghostty/WezTerm; set
    WezTerm opacity to 1.0 for deeper dark

- 🚀 Convenience
  - New `et` wrapper for terminal Emacs: picks truecolor terminfo and launches
    `emacsclient -t -a ""`
  - GUI: `emacsclient -c -n -a ""` returns immediately to the shell

#### 📅 **9-7-25**

- 🖼️ **qs-wallpapers ordering**: Alphabetical sorting fixed and made
  deterministic
  - 📂 Manifest sorting: prebuilt list now sorts case-insensitively using
    `sort -z -f` on NUL-delimited `find` output (stable across locales and
    filenames)
  - 🧭 UI sorting: QML model is populated from a case-insensitive name-sorted
    array; filtered results are also sorted
  - 🔁 Behavior: order is consistent regardless of cache; old manifests remain
    fine because UI-level sorting applies
  - 🧪 Verify: `qs-wallpapers --shell-only` to (re)build cache quickly;
    `qs-wallpapers-apply --print-only` to preview selection

#### 📅 **8-11-25**

- 🔧 **NeoVIM**: Fixed nvf configuration compatibility issues
  - 🔄 **API Update**: Replaced deprecated `extraConfigLua` with `luaConfigPost`
  - 🐛 **Build Fix**: Resolved NixOS rebuild errors related to nvf configuration
  - 📚 **Wordlist**: Improved `DirtytalkUpdate` automation for programming
    spellcheck
    - ✨ **Auto-download**: Wordlist now downloads automatically on first
      startup
    - 🔄 **Smart detection**: Only downloads if wordlist file doesn't exist
    - 💡 **Fallback**: Improved home activation script with better error
      handling
  - 🎯 **Compatibility**: Updated configuration to work with latest nvf version
  - ⚡ **Performance**: Added `vim.schedule()` for non-blocking wordlist updates

- 🔧 **Emacs**: Enhanced Nix LSP configuration for better development experience
  - 🎯 **Purpose**: Enables automatic evaluation of Nix inputs for better LSP
    functionality
  - 📍 **Location**: Added after the main LSP configuration in the config.el
    section
  - 🚀 **Benefits**:
    - 💡 Better code completion for Nix files
    - 🔍 Enhanced error checking and navigation
    - 🧠 Improved IntelliSense for Nix expressions
  - ⚙️ **Configuration**: Added `auto-eval-inputs = true` for nil LSP server

#### 📅 **8-10-25**

- 🔧 **ZSH**: Fixed `dm` alias and resolved home-manager activation issues
  - ⚡ Changed `dm` alias from deprecated `$HOME/.emacs.d/bin/doom run` to
    `emacs --no-desktop`
  - 🐛 **Fixed critical home-manager bug**: Home-manager activation was failing
    during rebuilds
  - 🔗 **Root cause**: File conflicts prevented home-manager from updating
    dotfiles since July 24th
  - ✅ **Resolution**: Manually activated correct home-manager generation, now
    auto-updates work
  - 🌐 **Multi-host compatibility**: Future zsh changes will now apply across
    all hosts using this config
  - 📝 **Syntax fix**: Corrected `alias dm = "command"` to `alias dm="command"`
    (removed spaces)
  - 🔄 **Verified**: Home-manager now properly activates without service
    failures

- ⚡ **CLI**: Added `rebuild-boot` function to `zcli`
  - 🔄 Uses `nh os boot` instead of `nh os switch`
  - ⏭️ Configuration activates on next restart instead of immediately
  - 🛡️ Safer for major changes, kernel updates, and system-critical
    modifications
  - 📝 Added to help menu: `zcli rebuild-boot`
- 📝 **Emacs**: Changed from `emacs-nox` to `emacs-pgtk`
  - 🖥️ Better GUI support with pure GTK implementation
  - 🎨 Enhanced graphics and theming capabilities
  - 🔧 Improved integration with modern desktop environments

#### 📅 **8-30-25**

- Editors: Added nano Home Manager module and Catppuccin-like nano config
  - New module: modules/home/editors/nano.nix (installs nano; manages ~/.nanorc)
  - Import wired into modules/home/default.nix
  - Theming: darker Catppuccin-like UI (title/status/error/prompt/selected
    panels)
  - NixOS-safe syntax include: include
    /run/current-system/sw/share/nano/\*.nanorc
  - Usability: line numbers, softwrap, tabstospaces, autoindent, matchbrackets,
    whitespace markers, smoother scrolling via unset jumpyscrolling, ^S to save
  - Fixes: removed invalid options; resolved parse errors; adjusted message
    panel color for readability

#### 📅 **8-9-25**

- Added `doom emacs` I blame Matt @TheLinuxCast. ;)
  - Run `get-doom` it will download and install all the packages needed
  - Language support for C,BASH,NIX,JSON,DOCKER,YAML,CSS/HTML,is included
  - `vterm` is also available
- Added `glances` server -`http://IP_ADDR:62210`
  - Th:wq ll:were is also a script `glances-server`
    - `glances-server start`
    - `glances-server stop`
    - `glances-server restart`
    - `glances-server logs`

#### 📅 **8-7-25**

- Added windowrule `windowrulev2 = noblur, xwayland:1`
  - Helps prevent wide borders on `xwayland` apps like `Davinci-Resolve` and
    `discord`
- Disabled `Davinci-Resolve` for non-Nvidia profiles
  - Only works with NVIDIA GPUs at the moment
- Moved more `modules/home` NIX files to subdirs with their own `default.nix`
- Begun process or moving apps in `modules/home` to their own subdirs

```text
 ./
├──  ags/
│   ├──  modules/
│   └──  user/
├──  bspwm/
│   ├──  picom/
│   └──  polybar/
├──  cli/
│   └──  fastfetch/
├──  dwm-setup/
│   └──  suckless/
├──  editors/
├──  hyprland/
│   └──  nwg-dock-hyprland/
├──  hyprpanel/
│   ├──  alternate.config/
│   ├──  scripts/
│   └──  themes/
├──  rofi/
├──  scripts/
├──  sherlock/
├──  suckless/
├──  terminals/
├──  waybar/
│   └──  scripts/
├──  wayfire/
│   ├──  change/
│   ├──  foot/
│   ├──  mako/
│   ├──  scripts/
│   ├──  waybar/
│   ├──  waybar-alt-4/
│   ├──  wlogout/
│   ├──  wofi/
│   ├──  wofifull/
│   ├──  wofifullt/
│   └──  wofit/
├──  wlogout/
│   └──  icons/
├──  yazi/
└──  zsh/
    └──  p10k-config/
```

#### 📅 **8-5-25**

- 🔄 **System**: Updated flake
- 🤖 **AI Tools**: Added `aider` and `claude-code` CLI AI clients
- 🖥️ **Desktop**: Re-enabled GNOME and BSPWM
- 🔧 **Config**: Converted BSPWM config files to NIX format
- 🎨 **GNOME**: Updated to enable select plugins not just install them
- 💻 **DWM**: Adding in Drew's DWM config!! It builds!! It's alive!

#### 📅 **8-4-25**

- 🎨 **Theming**: Made all menus use the same rofi config dark theme not stylix
- 📜 **Scripts**: Updated the scripts to use the new theme
- 🔍 **Menu**: Added `Sherlock` menu system to try it out. Nice wrong weather
  location
- 🔀 **Git**: Merged `main` branch to `Stable-v2.0`
- 🚢 **Dock**: Updated toggle script for `nwg-dock-hyprland`
  - 📝 Explained the purpose
  - ⚙️ Switch to variables for the various settings / menu
- 🎬 **Video**: Added `Davinci-Resolve`
  - ✅ Works perfect with NVIDIA GPUs (of course)
  - ⚠️ I have all the drivers for Intel and AMD but DR say no GPU
    - 🔧 Need to work on that more

#### 📅 **8-3-25**

- ⌨️ **Terminal**: Added alias `:q` to `eza.nix` to exit terminal
  - 👏 Thanks Wyatt
- 🖥️ **Foot**: Added `[float]` to foot terminal
- 🎯 **Cursor**: Correct updated syntax for `cursor.color` in `foot.nix`
- 🏷️ **Tags**: Added tag to foot binding `foot --app-id=foot-floating`
- 📐 **Window**: Then created a rule to float,center and set to 60%

#### 📅 **8-2-25**

- 🔧 **Formatting**: Updated NIX files format to NIX standard formatting
- 📊 **Waybars**: Added new waybars
  - 📋 `waybar-dwm.nix`
  - 📋 `waybar-dwm2.nix`
    - 💡 Inspired by Matt @TheLinuxCast

---

# 📚 **Version History**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<details>

<summary><strong>🗓️ July Changes</strong></summary>

#### 📅 **7-30-25**

- 🎨 **Graphics**: Re-enabled `GIMP`, `Rhythm box` they were failing to build
  before
- 📀 **Media**: Disabled override for `dvdauthor` it now also builds
- 🔍 **CLI**: Added `verify_hostname` to `zcli` to check for host entry
  - 👏 Thanks to `elyviere` for the code
- 💻 **Editor**: Added `hyprls` support to NeoVIM
  - ℹ️ Works on `.conf` files not NIX Hyprland config files
- 🖥️ **Login**: Moved SDDM login to left side, added more blur

#### 📅 **7-29-25**

- 🔗 **System**: Added URL for nixpkgs stable
- 🎵 **Audio**: Audacity failed to build due to upstream issue
- 📦 **Package**: Importing stable version 3.7.3 for now
- ✅ **Access**: Access to stable branch will be good thing to keep

#### 📅 **7-25-25**

- 💻 **Virtualization**: Added VirtualBox support to
  `modules/core/virtualisation.nix`

#### 📅 **7-24-25**

- 🆔 **System**: Added `hostID` to `variables.nix`
  - 💾 This is needed for `ZFS`
  - 👏 Thanks for Daniel Emerly for patch
- 📊 **Waybar**: Multiple waybar updates
  - ➕ Added new waybar `waybar-mecha.nix`
  - 📁 Updated hosts files with new waybar
  - 🔧 Corrected wrong file name
- 🔄 **System**: Updated flake
- ⬆️ **Upgrade**: Upgraded to Hyprland v0.50
- ⚠️ **Plugins**: Disabled all plugins
  - ❌ Won't build with HL v0.50
- 💻 **Laptop**: Added exception for `xps15`
  - 🖥️ Host `xps15` is older hybrid laptop
  - 🔒 Needs closed, stable drivers
  - 🔧 In `modules/drivers/nvidia-drivers.nix` added the exception
  - ⚙️ Added `environmental.variable` for nvidia offload for `xps15`
- 🎮 **GPU**: Added `nvidia-offload` env variables for Hyprland
- 📝 **Editor**: `NeoVim` popup asking to download word list
  - 💡 To resolve in Neovim run `:DirtytalkUpdate`
  - ⚠️ That is case sensitive
  - ✅ Enter `y` to download
  - 🔧 Fixed issue in `zcli` gpu detection for nvidia-hybrid broken

#### 📅 **7-13-25**

- 🔗 **Theme**: Added flake URL for `catppuccin`
- 🎨 **VSCode**: Applied `mocha` theme to `vscode`
- 📊 **System**: Applied `macchiato` theme to `btop`
- 🖥️ **GTK**: Disabled gtk in stylix using catppuccin module instead
- 🗑️ **Cleanup**: Removed GTK3/4 prefer dark theme in `gtk.nix`
- ✅ **Fix**: The catppuccin module resolves the `ptyxis` theme issue
- 🔧 **Git**: Themed `lazygit.nix` with catppuccin module
- 🌐 **Remote**: Themed `remmina.nix` with catppuccin module
- 🗑️ **Cleanup**: Removed `putty` from config not using and won't theme
- 📝 **Format**: Themed `remmina` with catppuccin and hosts are in nixfmt
- 🎨 **Manual**: Manually themed `btm` with catppuccin mocha theme
- ↩️ **Revert**: Had to revert some changes in `gtk.nix` as it broke GTK theme
- ✅ **Enable**: Re-enabled gtk in `stylix.nix`
- 🗑️ **Remove**: Removed `niri`
- ⚠️ **Font**: Commented out `symbola` font I get 404 errors

#### 📅 **7-12-25**

- 🔄 **System**: Updated flake
- 🛡️ **CLI**: Added defensive code to `zcli.nix` rebuilds and updates
  - ✅ Checks `hostname` and flake `host`
  - 🔧 If mismatched you'll be prompted to autocorrect it
- 🔀 **Script**: Had to split out `zcli.sh` from `zcli.nix`
  - ⚠️ NIX was interpreting shell variables as NIX variables
  - 🔗 Now `zcli.nix` calls `zcli.sh`

#### 📅 **7-11-25**

- 🔄 **System**: Updated flake
- 🗑️ **Cleanup**: Removed old hyprland dock launcher
- 🤖 **AI**: Added `gemini-cli` script that creates desktop file
  - ⌨️ It will start `gemini` in a kitty terminal
  - 🔑 If you have a `gemini` API key in `~/gem.key` The script will auto load
    it
  - 🌐 If not it will start normally you can use your google login
- 🗑️ **Remove**: Removed `doas.nix` doesn't work with PAM I.e. rebuilds fail

#### 📅 **7-10-25**

- 🚢 **Dock**: Added toggle for `nwg-hyprland-dock` `SUPER + SHIFT + D`
- 🖥️ **Display**: Updated the hosts on the KVM to 75Hz
- 🔄 **System**: Updated flake

#### 📅 **7-9-25**

- 🔄 **System**: Updated flake
- ⚙️ **QT**: Set `qt.Platform.name = lib.mkForce "adwaita";`
- ✅ **Fix**: This eliminates the warning on every rebuild b/c HomeMgr defaults
  to `gnome`
- 🔤 **Spellcheck**: Removed programming spellcheck I get prompted to d/l
  spellcheck file
  - ⏳ Waiting on response from nvf
  - 🗑️ Removed stale inputs for nitch and cursors. GH page gone

#### 📅 **7-8-25**

- 🎮 **GPU**: GPU detect set profile to `hybrid` instead of `nvidia-laptop`
- 📜 **Script**: Enhanced `install-ddubsos.sh` Now sets timezone and git user
  info
- 🎨 **Theme**: Added style and theme to `bat.nix`
- 🔧 **Modular**: Made `zcli` more modular for `zaneyos` and `ddubsos`
  - ⚙️ The variable `$PROJECT` sets which directory to use
  - 🔗 Keeping code the same between both projects more easily

#### 📅 **7-7-25**

- 📖 **Docs**: Added info on `zcli` in FAQ
- 🎵 **Audio**: Added low latency tweaks to `pipewire`
- 📊 **Monitor**: Added `bottom.nix` to enable / theme `btm` util
- 🖥️ **Niri**: Niri fixes
  - ⚙️ Added ENV variables suggested by `@pc` to config file
  - 🚀 Added `systemctl start --user xwayland-satellite.service`
  - 📐 Added window rule for niri to float download dialogs, etc
  - 🌐 Added another flag for wayland ozone support

#### 📅 **7-5-25**

- 🔄 **System**: Updated flake
- 📺 **Terminal**: Added popup windows to `tmux`
- 🔧 **CLI**: Added 'add-host' and 'del-host' to `zcli.nix`

#### 📅 **7-4-25**

- 🔄 **System**: Updated Flake
- 📁 **File Manager**: `Yazi` fixes
  - 🗑️ Removed `yy` from `.zshrc-personal`
  - ➕ Added `yy` function to `modules/home/yazi/default.nix`
  - ⚙️ Added `programs.yazi.shellWrapperName="yy'`

#### 📅 **7-3-25**

- 🔄 **System**: Updated Flake
- 🤖 **AI**: The `gemini-cli` script changed it to a nix-shell command
- 📊 **Fetch**: Added `nitch` min fetch util
- 🐚 **Shell**: Set `nitch` to run with zsh

#### 📅 **7-1-25**

- 🔄 **System**: Updated flake
- 🏠 **Hosts**: Added 'update-host' to `zcli.nix`
- 🤖 **Auto**: It will autodetect `host` and `profile` in `flake.nix`
- ⚙️ **Manual**: You can also pass that as parameters
  `zcli update-host HOSTNAME GPU`

</details>

<details>

<summary><strong>📅 June Changes</strong></summary>

#### 📅 **6-30-25**

- 🔄 **System**: Updated flake
- 📜 **CLI**: Added `zcli.nix` script
- 🔄 **Scripts**: `zcli update rebuild help` replacing aliases with a script
- 🗋 **Backup**: `zcli` also checks for `$HOME/.config/mime.apps.list.backup`
- 🛠️ **Cleanup**: You can also add more stale backup files to be removed before
  rebuilds

#### 📅 **6-29-25**

- 🔄 **System**: Updated flake
- 📐 **Window Rules**: Changed `windowrulev2` to `windowrule`
- 🎥 **Media**: Created `windowrule = content none, class:mpv`
- ✅ **Fix**: These stop `mpv` from going black when maximized and restoring
  from max
- 🎨 **Render**: Set `render send_content_type = false`
- 🔗 **Issue**: `https://github.com/hyprwm/Hyprland/issues/9786`
- 📦 **Packages**: Breaking up `modules/cores/packages.nix` into `req-packages`
  and `global-packages`
- 🎯 **Purpose**: To split out the minimum packages needed for `ddubsOS` vs.
  pgms you want on all hosts
- 🗋 **Cleanup**: removed old dead code
- 🎲 **Game**: Added `Space Cadet Pinball` flatpak. ;)

#### 📅 **6-27-25**

- 📜 **Script**: Updating `install-ddubos.sh` script
- ✨ **UX**: Nicer output, auto gpu detection, prompts to start rebuild
- 🔄 **Build**: Instead of `switch` is does a `nixos-rebuild boot`
- 🖥️ **SDDM**: For SDDM `nixos-rebuild switch` starts SDDM before rebuild
  completes
- 📝 **Logging**: Added logging and messages for success or build failures
- 🔄 **System**: Updated flake
- ↩️ **Revert**: reverted `helix-git` back to `helix`
- 🔧 **Fix**: fixed `modules/home/scripts/default.nix` wasn't being imported
- 🤖 **AI**: `gemini.nix` now builds the `gemini-install` script
- 🎮 **GPU**: Updating `install-ddubsos.sh` to detect GPU
- 🔍 **Detection**: If `lspci` not installed or GPU detected it will prompt user
  as before

#### 📅 **6-26-25**

- 💻 **Editor**: Added `evil-helix-git`
- 🔗 **Flake**: Added `chaotic` URL to flake
- ↩️ **Revert**: Reverted `gemini.nix` won't build the script
- 🤖 **AI**: Added `add-gemini-cli` to install google gemini cli ai
- 🎮 **GPU**: Undid `AQ_DRM` broke single NVIDIA system Need to make host
  specific
- 🔄 **System**: Updated flake
- 🔧 **GPU Backend**: Changed order in `AQ_DRM_BACKEND` (AQDRM)
- 🎯 **Priority**: `AQDRM` order changed to `/dev/card2:/dev/card1:/dev/card0`
- 🖥️ **Dual GPU**: On dual GPU system this made the `dGPU` being primary vs
  `iGPU`
- 🎵 **Music**: Added `youtube-music` Thank you `pC` for telling me about it
- 🗑️ **Remove**: Removed `libreoffice` from `core/packages.nix`
- ➕ **Add**: Added `libreOffice-fresh` to selected host packages file
- 📁 **Organize**: Moved most hyprland related apps to
  `home/hyprland/hyprland.nix`
- 🔄 **Restructure**: Moved optional apps from system section of `packages.nix`
  to optional section
- 📋 **Plan**: Plan is to have a `packages-core.nix` for just the required
  packages
- 📈 **Growth**: The current `packages.nix` has grown quite large
- 🤖 **AI**: Added `lmstudio` to selected hosts

#### 📅 **6-25-25**

- 🏠 **Host**: Added `bubo` host
- 🎮 **GPU**: Added `/dev/card2` to AQ backend devices in `hyprland.nix`
- 📊 **Monitor**: moved `nvtop.packagesFull` from `packages.nix` to hosts
  packages file

#### 📅 **6-24-25**

- 💻 **IDE**: Added `vscode.nix` Visual Studio with extensions added
- ⚙️ **Config**: Updated `variables.nix` for `ddubsos-vm`
- 🔄 **System**: Updated flake
- 🔧 **Fix**: Fixed `css` and `markdown` language formatter. Thanks to
  `mister_simon` for the fix
- 👏 **Credit**: Added `vscode.nix` vscode with extensions enabled thanks to
  `delciak` for the code

#### 📅 **6-22-25**

- 🔄 **System**: Updated flake
- ⌨️ **Keybinds**: Commented out `exit` binding `SuperShift C` because it's easy
  to mistake that for `CTRL SHIFT C` copy
- ⚠️ **Issue**: Not updating as a broken package upstream is causing `dvdauthor`
  not to build

#### 📅 **6-20-25**

- 🔧 **Hardware**: Fixed `hardware.nix` for `asus` host
- 🐚 **Shell**: Moved all common (zsh/bash/fish) shell aliases to `eza.nix`
- 🎨 **Theme**: Extracted `sddm-astronaught-theme` to
  `modules/core/sddm-astronaught-theme`

#### 📅 **6-19-25**

- 🔄 **System**: Updated flake
- 🎯 **Plugin**: Added `hyprFocus.nix` A plugin that animates when you focus on
  window
- ❌ **Disabled**: Currently disabled as it's broken
- 📢 **News**: Vaxry Announced 6/19/25 that it's now official plugin waiting for
  nixpkg
- 🗂️ **Refactor**: Added `eza.nix` to configure it for all shells and set base
  aliases

#### 📅 **6-18-25**

- 🎨 **UI**: Fixed colors in `sddm.nix`
- 🔧 **Fix**: Fixed aliases for rebuild and update
- 🖼️ **Wallpaper**: Added Vampire eyes girl to wallpapers
- 🛠️ **Env**: Added `ENV` variables for `TERMINAL` and `XDG_TERMINAL_EMULATOR`
- ⚠️ **Issue**: If you start `yazi` via `rofi` it runs from xterm which is
  horrible
- ↩️ **Revert**: Reverted `fu`, `fr` aliases to `nh` util Replacement aliases
  broken

##### 📅 6-14-25

- Updated flake
- Re enabled `markdown` issue with `deno` resolved upstream
- `nvf` language formatter calls `deno` which fails to build
- Disabled it in `modules/home/nvf.nix` for now until fixed upstream
- Changed face icon to ddubosOS logo (need to make image smaller)
- Disabled `markdown` formatted and now builds complete
- Added `atop` CLI utility simiilar to `glances` but better

##### 📅 6-13-25

- Change `zsh` aliases for fr/rebuild and fu/update to use `nixos-rebuild`
- Updated flake to test new aliases

##### 📅 6-12-25

- Updated flake
- Added `nix-flake` to inputs
- Reconfigured `flake.nix` to use that to configure and install flatpaks
- Also configured it to update flatpaks up nixos rebuilds
- Split `starship` prompt into two lines
- Added my default set of flatpaks
- Added `eww.nix` to enable eww widgets
- Code cleanup on hyprland `exec-once.nix` file Removed extraneous code
- NIX files in `modules/home` weren't updating using `nh`
- Added some suggested code in `flake.nix` Didn't resolve
- Switched to `nixos-rebuild switch --flake .#profile`
- That worked. Not sure if suggested code in `flake.nix` is still needed

##### 📅 6-11-25

- Added three git aliases `gs`, `gp`, `com`
- `gs` for `git stash`
- `gp` for `git pull`
- `com` for `git commit -a`
- Added `direnv` for VSCODE
- Added `zapzap` Whatsup Client
- Removed monitor setting for ixas caused error
- Changed `yazi` theme to catppuccin with `theme.toml` override
- Disabled stylix for `yazi`
- Disabled `transmission-qt` startup, always ran fullscreen at startup

##### 📅 6-10-25

- Updated flake
- Disabled `mpvpaper` python build/test was at 15hrs and still running
- Code cleanup, cleaned up `default` host config files

##### 📅 6-9-25

- Added `Macbook Pro` laptop
- Removed bridged network on `ixas`
- Enabled animation on manual resize
- Set opengl `nvidia_anti_flicker` to true
- Set render `explici_sync` to auto (2)
- Set cursor `hardware_cursors` to auto (2)
- Set cursor `hyprcursors` to true
- Set more values in `misc.nix`
- Enabled `qtutils` check
- Expanded settings in `xwayland`
- Added Zsh/Fish/Bash integration to `ghostty`
- Created `alacritty.nix` to configure alacritty terminal
- Removed `alacritty` from `niri.nix`
- Added shell integration, ZSH,BASH,FISH to `kitty.nix`
- Added `hyprscrolling` plugin _WIP_
- Added `neohtop` high end perf monitoring GUI
- Fixed typo in `transmission-qt` startup
- Disabled `hyprscrolling` bindings not working
- Added `pkill mako` to `exec-once.nix`
- Added Shell integration `(ZSH/BASH/FISH)` to `yazi`
- Added notification of rebuild/upgrade complete to nixos-rebuild aliases

##### 📅 6-8-25

- Updated flake
- migrated binding to use `uwsm`
- Changed default hyprland to rounded with icons
- Re-added `caligula` ISO burning CLI util

##### 📅 6-7-25

- Updated flake
- Added `UWSM` (Universal Wayland Session Mgr.) to hyprland
- Set default to `Hyprland-uwsm` (hyprland alone no longer supported)
- Added `uwsm app --` to bindings for terminals, thunar, etc
- Added `uwsm app --` to Hyprland startups
- Changed `swww init` to `swww-daemon` `init` is depreciated
- Updated more apps to use `uwsm`
- Fixed typos in `binds.nix`
- Updated `LICENSE` with my name and 2025
- Enabled `virt-manager` and created bridge network on `ixas` host
- Added gnome-boxes GUI F/E for QEMU

##### 📅 6-6-25

- Updated flake

##### 📅 6-5-25

- Added `SDDM` need change colors
- Updated flake
- Added `warp` terminal
- Removed dup packages from `packages.nix` for wayfire
- Re-Added `vscode`
- Re-formatted `ixas/hardware.nix` to nixfmt
- Re-formatted `prometheus/hardware.nix` to nixfmt
- Re-formatted `xps15/hardware.nix` to nixfmt
- Removed `nixstation` host. Leftover form ZaneyOS

##### 📅 6-4-25

- Updated flake
- Edited `niri` config `config.kdl`
- `waybar` now starts from `~/.config/niri/waybar`
- Added Paridah's `Hyprpanel` `config.jsonc`

##### 📅 6-2-25

- Changed `sshd` settings, `no root login`, `passwd` yes
- Made `neovim` default editor
- Updated flake
- Cleaned up old `niri` config files
- Added options to git
- GIT: Added timer for ssh
- GIT: Added log.decorate date to ISO format
- GIT: Added push type simple
- GIT: Added initial branch main
- GIT: Added log.decorate to full
- GIT: Added merge conflict style to diff3
- GIT: Added aliases for git command `git log`, `git df`, etc

##### 📅 6-1-25

- Yazi update, requires "manager" to be changed to "mgr" (really?)
- Fixed binding for hyprland and niri rofi menus to use my config
- Starting to break up hyprland config
- Still getting gnome warning on obsolete option even though I changed it
- Set ptyxis to catpuccin theme
- Moved Hyprspace plugin to `hyprspace.nix`
- Moved Hyprtrails plugin to `hyprtrails.nix`
- Moved Hyprexpo pluging to `hyprexpo.nix`
- Reformatted `xerver.nix` to remove warning msg about gnome.enable
- Error remains but not formatting is more correct regardless
- Updated flake
- Added starship prompt
- Disabled powerline 10k prompt
- Added fzf.nix to theme/customize it
- Added lazygit.nix disable popup and theme it
- Tweaked zsh settings
- FZF: Added preview window and binding to edit with enter

</details>

<details>

<summary><strong>📅  May Changes</strong></summary>

##### 5-31-25

- Updated flake
- tmux now in nix code format
- Removed home mgr tmux directory - not needed
- Removed some old files no longer needed
- Added `start-polkit-agent` for niri and wayfire

##### 5-30-25

- Added `Jerry-waybar.nix`
- Added `animationms-moving.nix`
- Added `waybar-ddubs-2.nix`
- Updated flake

##### 5-29-25

- Updated flake
- Pinned kernel to 6.14 NVIDIA and VL42L loopback fail

##### 5-28-25

- Updated flake
- Ported yazi patch from zaneyos

##### 5-27-25

- Updated flake
- Enabled NVIDIA support to docker
- Set it `nvidia-drivers.nix` and `virtualization.nix`
- Enabling in `virutalization` is depreciated but starting with both enabled
- Using NVIDIA beta drivers (575) might need to switch to stable
- Removed NVIDIA support for docker (didn't work)
- Disabled ollama/openUI docker containers (didn't work)
- Re-enabled hyprtrails. It's now buiilds
- Created very simple wofi powermenu need to theme

##### 5-24-25

- updated flake
- re-installed IXAS host
- updated niri scripts to `env`
- Set resolution for `Virtual-1`
- Set resolution for `HDMI-A-1`
- Added swaylock, mako, swaybg for niri

##### 5-23-25

- Updated flake
- Added niri.nix to copy config files
- Updated wayfire.nix to copy config files

##### 5-22-25

- Upd flake
- Added niri and wayfire (Phase 1)
- Enabled lightDM
- Added wayfire and niri config files partiall edited (Phase 2)

##### 5-21-25

- Updated flake
- Changed to NVIDIA open drivers per wiki
- https://wiki.nixos.org/wiki/
- Switched to beta drivers 575
- Formatted explorer HW file to json NIX fmt

##### 5-19-25

- Updated flake
- Added `uwsm` to packages
- Added DaVince Resolve to explorer
- Hyprtrails plugin still fails to build

##### 5-18-25

- Updated to 25.11
- Created `exec-once.nix` and `env.nix` for Hypland config
- Commented out `nmg-dock-hyprland` in `exec-once.nix`

##### 5-17-25

- Added sox for ffmpeg
- Added ZaneyOS v1 rofi menu (need to implement)
- Updated flake
- Creating `ffmpegedit` script from Zaney's script
- Hyprland updated to 0.49 Breaks hyprtrails plugin

##### 5-15-25

- Disabled nag messages for donations
- Left update_news enabled for now
- Re-enabled VRR set to 1
- Changed app rofi menu to compact catppuccin one
- Changed to `sudo-rs` (rust) set wheel to nopasswd
- Cleaned up `wf` script removed v1 code
- Got nice nvf config and added floating diags back!
- Thank you @nezia1
- More additions to `nvf.nix`
- More formatting cleanup on hosts config files
- Added `nwg-dock-hyprland`
- Got configuration from ML4W
- Fixed `nwg-dock` to ignore drop-terminal
- Enabled hyprlock to resolve PAM issue

##### 5-14-25

- Added ags v1 and ags overview SUPER + A
- Added config files for overview
- Added wfetch and created `wf` script to alternate waifu logos
- Updated flake
- Enable wayland for wezterm
- Updated `wf` script for three more options randomized

##### 5-13-25

- Updated flake
- Re-enabled printing avahi builds in VM
- Disabled use.systemclipboard in `nvf.nix`
- It's no longer supported, have to use `vim.clipboard.registers`
- Whatever the heck that is.

##### 5-12-25

- Updated flake
- Added markdown preview and `ts prettierd`
- Add NVIM map for `neotree` `space e`
- Removed `vscode-fhs`
- Added zapzap
- Disabled printing avahi daemon fails

##### 5-11-25

- Turned off `treesitter.context` in `nvf.nix` (floating preview up top)
- Added games to explorer
- Updated flake
- Added mpd service as a test `mpd.nix` but doesn't build
- Trying different version of `mpd.nix`
- Added `doas` as extra option besides `sudo`

##### 5-10-25

- Updated flake
- Added Paridah's waybar `waybar-nekodyke.nix`
- Added assaultcube to prometheus (good game)

##### 5-9-25

- Updated flake
- Added urbanterror and vanquished to prometheus

##### 5-7-25

- Working on Hyprpanel with Home Mgr (broken ro configs)
- Updated flake
- Added gnome and most of the extensions I need ex. Dash2DockAnimated
- Added a few more gnome packages
- Upped wezterm opacity to 0.75
- Updated hm-find with better messaging and log directory check
- Updated nvf to enable rainbow colored pair matching
- Enabled banner for neovim. Trying to theme it now
- Added source for monitors and workspaces from NWG-DISPLAY

##### 5-6-25

- Added pandoc and other nwg utils (for testing)
- Removed light bulbs from NVF config (finally)
- Updating README.md for ddubos removing zaneyos references where needed
- Fixing install script to work with ddubosos
- Small changes to `default` host config file
- Changed ddubsOS version to 2.0 Since it's total re-do from 1.x
- Created hm-find shell script to find hm files that can't be backed up
- Added tranmission-qt bittorrent client
- Added tranmission-qt to Hyprland BSPWM startup
- Adding old waybar from ddubos-v1 (WIP)
- Updated flake
- Added luarocks, nvim, luacheck

##### 5-5-25

- Got vim.diagnostics config'd in `nvf.nix` working
- Changed NVF.NIX to make diag screen smaller
- Added these keymaps to use diags
- Added glab gitlab cli tools
- Fixed ddubsOS references to ddubsos
- Rebuilt and updated flake as test

```lua
{
          key = "<leader>dj";
          mode = ["n"];
          action = "<cmd>Lspsaga diagnostic_jump_next<CR>";
          desc = "Go to next diagnostic";
        }
        {
          key = "<leader>dk";
          mode = ["n"];
          action = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
          desc = "Go to previous diagnostic";
        }
        {
          key = "<leader>dl";
          mode = ["n"];
          action = "<cmd>Lspsaga show_line_diagnostics<CR>";
          desc = "Show diagnostic details";
        }
        {
          key = "<leader>dt";
          mode = ["n"];
          action = "<cmd>Trouble diagnostics toggle<cr>";
          desc = "Toggle diagnostics list";
        }
      ];
```

##### 5-4-25

- Added ixas AMD mini
- Added `hp.reset` script to restart Hyprlpanel waiting for fix
- Updated flake
- Added Pinta simple paint pgm
- Updated Remmina hosts config files

##### 5-3-25

- Updated flake - New kernel & NVIDIA drivers
- Updated explorer to current code base
- Added script to toggle master / slave and send notification SUPER + SHIFT +M
- TMUX plugins not getting copied (??)

##### 5-2-25

- Added script 'ff' for fastfetch alternate config file
- Added alternative fastfetch config file to fastfetch default.nix file
- Removed -e fish from terminals
- Added scripts for hyprland to .local/bin until fix avail
- Updated flake
- Added copying the hyprpanel scripts to $HOME/.local/bin as a workaround

##### 5-1-25

- Finally fixed tmux.conf
- Redid shortcuts in Dashboard panel
- Added thunar, emojipicker
- Removed cpu,mem performance metrics
- Updated FAQ.md moving ZaneyOS refs to ddubsOS
- Updated flake
- Reset resolution for mini-intel for new monitor

</details>

<details>

<summary><strong> 📅 April Changes</strong></summary>

##### 4-30-25

- 🎨 **Theme**: Configured Ghotty terminal for catppuccin-mocha
- 🎨 **Theme**: Configured Kitty terminal for catppuccin-mocha
- 🎨 **Theme**: Configured hyprpanel to catppuccin-mocha
- ✅ **Fix**: Fixed Remina.nix not saving hosts in correct directory
- 🎨 **Theme**: Configured ptyxis terminal for catppuccin-mocha
- 🎨 **Theme**: Configured evil-helix for catppuccin-mocha
- ✅ **Fix**: Typo in GhosTTY config
- 🔋 **Power**: Added power-profiles-daemon
- ⌨️ **Tmux**: Added tmux config
- ⌨️ **Tmux**: Tweaked TMUX config set theme to catppuccin-mocha
- 📖 **Docs**: Updated FAQ with new tree entry for TMUX
- 🎮 **GPU**: Disabled NVIDIA on Hybrid laptop Flatpaks wouldn't run
- 🖥️ **VM**: Changed zaneyos-v23 VM to ddubsos-vm
- 🔄 **System**: Updated flake
- ✅ **Fix**: Typo in tmux theme name
- 🎨 **Theme**: Imported colors directly into tmux.conf

##### 4-29-25

- 🖼️ **Wallpaper**: Added mpvpaper
- ⌨️ **Aliases**: Added aliases for 'rebuild' and 'update'
- ❌ **Aliases**: Disabled the 'zu' update aliases until I can fix where it gets
  install script
- 🖼️ **Wallpaper**: Added mpvpaper
- 📦 **Package**: Added figlet. I swore it was already there
- 💡 **PR**: Added PR for hyprpanel nixpkg to test before it's added to repo
- ⚙️ **Flake**: Commented out the flake input for now
- 📦 **Package**: Formally added gpu-screen-recorder hyprpanel uses it
- ⚙️ **System**: Reduced swappiness to 10
- 📊 **Hyprpanel**: Changed back to Hyprpanel Source for now until NixPkg ready
- 📐 **Window Rules**: Wezterm and ghostty weren't in the windows rules
- 📐 **Window Rules**: Removed MPV from float class
- 🏷️ **Tags**: Added MPV and VLC to video tag
- ✨ **Opacity**: Set video tag to 1.0/1.0 Opacity

##### 4-28-25

- 🔄 **System**: Updated flake
- 🎬 **Video**: Added kdenlive to mini-intel

##### 4-27-25

- ⚙️ **NH**: nh 4.0 uses NHFLAKE, not 'FLAKE'
- ✅ **Fix**: Fixed fish.nix nh using wrong profile
- 💡 **Hyprpanel**: Started to try fix hyprpanel.nix to create writable config
  files w/o my hack
- 🌐 **DNS**: Added local DNS info for my hosts to resolve DNS issue
- 🆔 **Project**: Changed flake and fastfetch to ddubsOS Prep for ddubsOS v1.0
- 🆔 **Project**: Changed everything except install/upd scripts to ddubsOS
- 🔄 **System**: Updated flake neovim upgrade
- 📖 **Docs**: Updated FAQ.md for ddubsOS references need to finish re-do of
  upgrade section

##### 4-26-25

- 🔄 **System**: Updated Updated
- ⚙️ **NFS**: Updated NFS options explorer host

##### 4-25-25

- 🔄 **System**: Updated flake
- ⌨️ **Terminal**: Added -e fish to default terminal binding
- ⌨️ **Keybinds**: Added SUPER + ALT + ENTER for wezterm -e fish
- ⌨️ **Keybinds**: Added SUPER + CTRL + ENTER for foot -e fish
- 🎨 **Stylix**: Removed btop from stylix.nix
- ⌨️ **Terminal**: Added -e fish to dropdown term
- ✅ **Fix**: Fixed alias is zshrc-personal
- 🐚 **Fish**: Added more aliases to fish.nix
- 📁 **ZSH**: Finally moved .zshrc-personal.nix back to zsh dir
- ⌨️ **Alias**: Created alias for `up` function `upd` can't get it to work
  otherwise
- ⌨️ **Terminal**: Added and configured ptyxis terminal

##### 4-24-25

- 🕰️ **Clock**: Added date to clock
- 🌐 **Browser**: Added vivaldi
- 💻 **Laptop**: Set logind to ignore lid switch
- 🔄 **System**: Updated flake
- ✅ **FIX**: FIXED LAPTOP login screen issue
  ```
  boot.kernelParams = [
    "video=HDMI-A-1:e"     # Enable HDMI-A-1 (external monitor)
    "video=eDP-1:d"        # Disable eDP-1 (laptop screen)
  ];
  ```
- ✨ **Login**: Disables eDP-1 and forces HDMI-A-1 on so greetd shows up on
  monitor
- ✨ **Login**: Looks cleaner now
- 💻 **Laptop**: Added XPS15 hybrid laptop
- ⌨️ **Terminal**: Added foot and configured with some basic Added options
- 🎨 **Stylix**: Disabled foot in stylix.nix
- ✨ **Hyprpanel**: Set hyprpanel transparent Could not find good color
- 🐚 **Fish**: Added fish and started to configure it. Can't get aliases working
- 🧩 **Fish**: Added fish plugins
- ✅ **Fish**: Got aliases working had to be under prgrams.fish.shellAliases

##### 4-23-25

- ✨ **Hyprpanel**: Slight modification to font weight in hyprpanel
- ✨ **Hyprpanel**: Makes hyprpanel look cleaner now
- ⚙️ **Config**: Overwrote rounded config with square
- ⚙️ **Config**: Copied rounded config to
  modules/home/hyprpanel/config.json.rounded.with.icons
- ✨ **Hyprpanel**: Small tweaks to hyprpanel
- 🌐 **Remmina**: Added Pluto & Explorer to remmina config
- 🎨 **Theme**: Changed nvim them to cattputccin
- 🎨 **Stylix**: Disable nvf in stylix.nix
- 📜 **Script**: Updated screenshotin script Added error checking and notiy
  Needs more work
- ✅ **Fix**: Fixed depreciation warning on programs.zsh.initExtra to
  initContent
- 🔀 **Merge**: Merged change on zaneyos as well.
- 📜 **Script**: Added 2nd screenshot script for satty for editing/annotating
  screenshots
- 📜 **Script**: Edited 1st screeenshot script for shorter notify messages

##### 4-22-25

- 🔄 **System**: updated flake
- ❌ **NVF**: Disabled NVF for now
- ⚙️ **NVF**: Manually installed nvchad
- 💡 **NVF**: There is flake for it but I need Zaney to install
- 🔗 **NVF**: https://github.com/nix-community/nix4nvchad
- ✅ **NVF**: For now turned NVF back on

##### 4-21-25

- ⌨️ **Keybinds**: Added binding SUPER + SHIFT + P for putty
- ⚙️ **Putty**: Added basic config + sessions file to zaneyos/modules/home/putty
- ⚙️ **Putty**: Added putty.nix which creates writeable files outside of NIX
  store
- ⚙️ **Hyprpanel**: Added Hyprpanel.nix creating writable config files
- ⚙️ **Remmina**: Added remmina.nix to create writable config files
- 📦 **Nwg-apps**: Added nwg-apps.nix to optionally install these apps

##### 4-20-25

- 🔄 **System**: updated flake
- ⌨️ **Terminal**: Set postion for dropdown terminal more centered
- ⚙️ **Helix**: Made evil-helix.nix has enable/disable feature
- ⌨️ **Keybinds**: Moved my alternate keybinds for floating to the other default
  settings

##### 4-19-25

- 🏠 **Host**: Added host asus
- ⌨️ **Keybinds**: Added SUPER + V clipboard manager using clipman
- 📝 **Editor**: Added evil-helix starting to configure it
- 📝 **Editor**: Adding hints and syntax diagnostics to helix
- 📝 **Editor**: Added more language servers, lua, yaml, etc

##### 4-18-25

- ⌨️ **Wezterm**: Updated wezterm failback fonts
- ⌨️ **Wezterm**: Added default_prog entry in case someone uses starship
- ✨ **Wezterm**: Thanks to Drew @justaguylinux Wezterm detects NVIDIA &
  disables wayland
- 🔄 **System**: Updated flake
- ✨ **Hyprspace**: Adjusted padding, margin and gaps for hyprspace. Much better
- ⌨️ **Keybinds**: Added SUPER + T for thunar

##### 4-17-25

- 🔄 **System**: Updated flake
- ⚙️ **Hyprpanel**: Added alernate hyprpanel config

##### 4-16-25

- ⌨️ **Terminal**: Increased size of dropdown terminal
- ⚙️ **Hyprpanel**: Had to disable swaync and dunst to get hyprpanel to start
- ⚠️ **Hyprpanel**: Still takes 15+ seconds to open
- ⚙️ **Hyprpanel**: Added alternate config for Hyprpanel - needs some edits
- ⚙️ **Hyprpanel**: Updated alternate config for Hyprpanel
- ✅ **Dunst**: Re added dunst added pkill in hyprland startup
- ✨ **Hyprpanel**: Tweaked the hyprpanel config a little more
- 🎨 **Theme**: Added oxocarbon theme to config and added that config to
  alternate.config dir

##### 4-15-25

- 🔄 **System**: Updated Updated flake
- 🖼️ **Wallpaper**: Added a few more wallpapers

##### 4-13-25

- 🔧 **Yazi**: Had to manually update Yazi Plugins for Yazi v25.04.8
- ⚠️ **Workaround**: This is a temp workaround as another update could/will
  break it
- 💡 **Yazi**: NixPkgs now has Yazi Plugins got this link
- 🔗 **Yazi**:
  https://github.com/llakala/nixos/blob/main/apps/core/yaziPlugins/yazi-plugins.nix

##### 4-12-25

- ⚙️ **Startup**: added killall -q several times on swww and swaync
- ⚙️ **Startup**: Removed `^` from hyprpanel at startup
- ✅ **Fix**: Seems to have resolved getting hyprpanel to start

##### 4-11-25

- 🎨 **Font**: Changed font for Hyprpanel to Maple Mono
- ⚙️ **Startup**: Set default to hyprpanel at startup
- 🎨 **Font**: Changed Kitty terminal font to Maple Mono
- 🎨 **Font**: Changed ghostty terminal font to Maple Mono
- 🎨 **Font**: Changed wezterm terminal font to Maple Mono
- ⚙️ **ANR**: Created option to disable ANR
- ⚙️ **ANR**: Increased ANR ping threshold from 1 to 5 as starting point Default
  value of 1 is WAY too sensitive
- 🎨 **Font**: Set default Hyprland font to Maple Mono
- ⚙️ **Startup**: Fixing startup for hyprpanel killing swaync
- ⚙️ **Startup**: Added more pkills to try to really kill swaync ;)
- 🔄 **System**: Updated flake. Still trying to kill swaync startup
- ✅ **Fix**: Added a kill swaync after starting hyprpanel seems to work
- ✨ **Hyprpanel**: Small changes to hyprpanel config
- 📦 **Package**: Added LibreOffice

##### 4-10-25

- 🔄 **System**: Updated flake
- 🖥️ **BSPWM**: Added arandr for bspwm
- 🖥️ **BSPWM**: Added xrandr config to bspwmrc to set resolution

##### 4-9-25

- 🔄 **System**: Updated flake
- 🎨 **Fonts**: Added more fonts

```text
fonts = {
   packages = with pkgs; [
     dejavu_fonts
     fira-code
     fira-code-symbols
     font-awesome
     hackgen-nf-font
     ibm-plex
     inter
     jetbrains-mono
     material-icons
     maple-mono.NF
     minecraftia
     nerd-fonts.im-writing
     nerd-fonts.blex-mono
     noto-fonts
     noto-fonts-emoji
     noto-fonts-cjk-sans
     noto-fonts-cjk-serif
     noto-fonts-monochrome-emoji
     powerline-fonts
     roboto
     roboto-mono
     symbola
     terminus_font
   ];
 };
```

##### 4-8-25

- 🔄 **System**: Updated flake

##### 4-5-25

- 📐 **Window Rule**: Added rule to float nwg-displays
- ✅ **NVF**: Removed lsplines from nvf.nix it's no longer supported
- 🔄 **System**: Updated flake

##### 4-4-25

- 🔄 **System**: Updated flake
- 🗑️ **Packages**: Removed old packages, SDL,SDL2,libX11
- 🗑️ **BSPWM**: Removed BSPWM apps from packages.nix they are in bspwm.nix
- ⚙️ **SDL**: Set SDL_BACKEND to wayland. Was x11 but doom game stopped working
- ⚙️ **Hyprland**: Added `force_split = 2 #always split to right or bottom` to
  hyprland.nix
- 📐 **Window Rule**: Added `tag +settings, class:(.blueman-manager-wrapped)` to
  WindowRules.nix so the bluetooth manager settings will float not tile

##### 4-3-25

- 📐 **Window Rule**: Set waypaper to floating

##### 4-2-25

- ⚙️ **Hyprland**: Added options in hyprland.nix for vfr and vrr
- ⚙️ **VFR**: set vfr Variable Frame Rate to true
- ⚙️ **VRR**: Set vrr Variable Refresh Rate to 0 (disabled)
- 💡 **NVIDIA**: I believe VRR causes more issues than it fixes w/NVIDIA
- 📖 **Docs**: Added updated FAQ.md
- 📦 **Virtualization**: Enabled virtmgr and docker
- 🎨 **Stylix**: Disabled stylix for wexterm
- 📦 **Docker**: Added Lazydocker
- 🖼️ **Wallpaper**: Deleted some wallpapers
- 🔀 **Git**: Added gitnuro GUI for GIT
- 🗑️ **Packages**: Removed lazydocker from pacakages it's in virtualization.nix
- 🎨 **Theme**: Changed wezterm them to Aadvark Blue
- 🎨 **Theme**: Added other color themes also, commented out
- ⚙️ **Wezterm**: Enabled wayland support for wezterm
- 🖼️ **Wallpaper**: Disabled wallsetter & set waypaper --restore
- ℹ️ **Inxi**: Added glxifno for inxi -G gpu support
- 📊 **GPU**: Added GPUviewer fronteng GUI to glxinfo
- ⚠️ **SWWW**: Had to disable swww im on startup it overwrote waypaper --restore
- 🏷️ **OBS**: Added tag OBS and WindowRule to move to WS10

##### 4-1-25

- 🔄 **System**: Updated flake
- ⚙️ **Host**: Updated mini-intel to current spec
- ⌨️ **Keybinds**: Disabled specialworkspace binds, I don't use them
- ⌨️ **Keybinds**: Change to togglefloat and allfloating
- 🛠️ **Host**: Update explorer nvidia PC - also broke NVIM LSP
- 🎨 **Fonts**: Added more fonts

```text
dejavu_fonts
noto-fonts
noto-fonts-cjk-sans
noto-fonts-cjk-serif
noto-fonts-monochrome-emoji
nerd-fonts.im-writing
nerd-fonts.blex-mono
inter
maple-mono.NF
ibm-plex
```

</details>

<details>

<summary><strong>📅 March Changes </strong></summary>

##### 3-31-25

- ⚙️ **Hyprland**: Hyprland v0.48.1 released to fix xwayland
- ⚠️ **LightDM**: However, when lightDM enabled after login no KB/mouse
- ❌ **LightDM**: Disabled LightDM for now
- 🔄 **System**: Updated flake

##### 3-30-25

- ⌨️ **Keybinds**: Added binging for waypaper SUPER + CTRL + W
- 📖 **Docs**: Updated FAQ.md cleaned up formatting added many more icons

##### 3-29-25

- ⬇️ **Hyprland**: DOWNGRADED Hyprland to 47.2
- ❌ **Xwayland**: Xwayland broken and lightDM won't start
- ❌ **Input**: When it does the mouse and keyboard are dead
- ✅ **BSPWM**: Enabled startx and using GreeterD to start BSWPM
- 💾 **Branch**: Saved broken build in new branch

##### 3-28-25

- 🔄 **System**: Updated flake
- 🌐 **Browser**: Turned off firefox enabled brave
- ⌨️ **Keybinds**: Remapped keybindings (no prtscr or ins key)
- ✨ **Polybar**: Small polybar changes, tray to left, more margins
- ⚙️ **WM**: Changed wm-stacking to bspwm, was i3
- ⚙️ **Session**: Set default session to Hyprland
- ⚙️ **BSPWM**: Enabled bspwmm in Home Mgr.
- ⚙️ **Hyprland**: Added hyprland-qtutils for ANR/banners
- ⚙️ **BSPWM**: Added bspwm, sxhkd config files
- ✅ **Fix**: fixed bspwm.nix to copy config files
- 📜 **Script**: Updated keyhelper.sh to use env bash
- ⬆️ **Hyprland**: Updated to hyprland v0.48

##### 3-27-25

- ❌ **BSPWM**: Can't get bspwmrc to work via home mgr
- 💾 **LightDM**: Saving working setup for lightdm but it won't start HL
- ✅ **FIXED**: FIXED. programs.hyprland.enable was not set So no desktop file
- ❌ **Greeter**: Disabled slick greeter - can't theme propery yet
- ⚙️ **BSPWM**: Added polybar, sxhkd, picom configs to modules/home

##### 3-26-25

- 🔄 **System**: Updated flake
- 📝 **Format**: Reformatted explorer/hardware.nix to nixfmt
- ➕ **Desktop**: Added lightDM and BSPWM
- ⚙️ **Config**: Added config files in HM for BSPWM, polybar, sxhkd

##### 3-24-25

- 🔄 **System**: Updated flake
- ⚙️ **Hyprpanel**: Edited hyprpanel config
- ⌨️ **Keybinds**: Added SUPER + K keybinding for binding search menu
- 📖 **Docs**: Updated FAQ.md
- 📦 **Package**: Added jq to format json files
- 🎨 **Theme**: Added themes for hyprpanel
- 📁 **Directory**: Added directory hyprpanel to save files

##### 3-23-25

- 🔄 **System**: Updated flake
- ⚙️ **Hyprpanel**: Added Paridhi's config to hyprpanell
- ⚙️ **Hyprland**: Changed Windowrulev2 to windowrule for v0.48 change
- 🗑️ **Games**: Removed fullscreen rule for games Doesn't work anymore
- 💡 **Waybar**: Had hyprpanel starting by accident reverted to waybar
- 📐 **Window Rule**: Added rule for discord to start in WS 3
- 📐 **Window Rule**: Added rule for browser start in WS 2
- 🏷️ **Tags**: Added discordcanary to im tags
- ↩️ **Revert**: Had to reset windowrulev2 for 0.47

##### 3-22-25

- 🔄 **System**: Updated flake
- ⚙️ **System**: Added cpuFrequencyGoverner to performance in system.nix
- 🖼️ **Wallpapers**: Added (again) my wallpapers :( )
- ⚙️ **Startup**: Set wallsetter to run at startup
- ⏰ **Timer**: Changed timer to 48 mins (2880 seconds)
- ⚙️ **Hyprpanel**: Added input for hyprpanel
- ❌ **Services**: disabled swww, swaync
- ⚙️ **Startup**: Added hyprpanel to startup
- 📦 **Apps**: Added OBS and wl-screenrec

##### 3-21-25

- 🔄 **System**: Updated flake
- 📦 **CLI**: Added GDU go disk usage
- 📦 **Package**: Re-added virt-viewer after it moved to virtualization.nix
- ✨ **Prompt**: Added hostname to prompt
- 🗑️ **Apps**: Removed brave and ouch
- 🌐 **Browser**: Set google-chrome-stable as default

##### 3-20-25

- ✨ **Release**: v2.3 released!
- ✅ **Thunar**: Enabled thunar on all hosts
- 📦 **App**: Added resources app
- ⬆️ **Branch**: Updated to unstable branch
- 🏠 **Hosts**: Added my hosts and updated the variables for thunar
- 🔀 **Merge**: First pass at merging my changes, say a prayer for me
- ⌨️ **Kitty**: Changed kitty new window to open new window current dir
- ⌨️ **Bindings**: Changed bindings to open discordcanary, thunar and vscode
- ✅ **Fix**: Fix waybar-ddubs.nix icons too small
- 🖥️ **Display**: Added nwg-displays to generate monitor config files
- 🔄 **System**: Updated flake
- 🖼️ **Wallpapers**: Added a few more wallpapers
- ❌ **Misc**: Disabled Misc->swallow to insure it's off

##### 3-19-25

- ✨ **Kitty**: kitty enabled cursor trails
- ⚙️ **Kitty**: Kitty enabled wayland backend
- ✨ **Hyprland**: Added gestures to Hyprland config.nix
- ⚙️ **Startup**: Disabled logo and splash screen at startup
- 📐 **Window Rule**: Float windows override
- ⚙️ **XWayland**: Enabled xwayland force whole scaling
- 📖 **Docs**: Documented variables.nix with available animations
- ⬆️ **Sync**: Updated my dev to current zaneyos build RC1

##### 3-18-25

- 🖼️ **Wallpapers**: Added wallpapers

##### 3-17-25

- ✨ **Animations**: Added animations-def, -end4, -dynamic
- 📁 **Refactor**: Moved Windowsrules to windows-rules.nix
- 🗑️ **Animations**: Removed animations from config.nix
- ⚙️ **Variable**: Added variable animChoice to variables.nix
- ⚙️ **Default**: set default to end4 anims in all host variables.nix files
- ✅ **Fix**: fixed syntax errors in animations files

##### 3-16-25

- 🔄 **System**: Updated flake
- ⚙️ **Kernel**: Changed boot kernel to 6.12 for NVIDIA explorer host
- 🎨 **Theme**: Changed ghostty them to Aura
- ✨ **Cursor**: Added cursors to hyprland.conf
- ⚙️ **NVIDIA**: Added ENV variables for NVIDIA

##### 3-16-25

- 🔄 **System**: Updated flake
- ⚙️ **Kernel**: Changed to 6.13 kernel for non-Nvidia hosts
- ❌ **Plymouth**: Disabled plymouth startup logo
- ⚙️ **htop**: Added htop.conf and updated default.nix
- 🧩 **Plugins**: Added hyprtrials and hyprexpo
- 🧩 **Plugin**: Added hyprspace
- 🖼️ **Wallpaper**: Added waypaper
- 🖼️ **Wallpaper**: Added my wallpapers back in
- ✅ **Fix**: Fixed discord binding
- ⌨️ **Keybind**: Added SUPER+ALT+S for screenshoting some VM trap SUPER

##### 3-15-25

- ⬆️ **Sync**: Major update sync'd with zaneyos current
- ✨ **Waybar**: Waybar and stylix image selectable in variables.nix
- ✅ **Yazi**: yazi is there by default.
- ⚙️ **Hosts**: Updated all variables files to use waybar-ddubs.nix
- 🎨 **Fonts**: Added firacode and firacode-symbols to fonts.nix
- 🎨 **Fonts**: Changed firacode nerd to just firacode in wezterm.nix
- ⚙️ **Ghostty**: Updated GHOSTTY config with keybindings and sample themes

##### 3-14-25

- ✅ **Fix**: Fixed tmux.nix and yazi.nix nix empty function
- 📖 **Docs**: Udpated FAQ.md with kitty keybindings

##### 3-13-25

- ⚙️ **Tmux**: Added tmux.nix to config nix
- 🗑️ **Cleanup**: Cleaned up yazi.nix but need more done
- 🖼️ **Wallpaper**: Added wallpaper
- 🐚 **Shell**: Added ZSH / BASH integration to zoxide

##### 3-12-25

- ⚙️ **htop**: Added cool htop.nix config
- ⚙️ **eza**: Added eza.nix config
- ⚙️ **zoxide**: Added zoxide.nix config
- ⚙️ **fzf**: Added fzf.nix config
- 📖 **Docs**: Updated FAQ ver/date Added info on NVIDIA-Hybrids Spelling errors
- 🎨 **Waybar**: Modified waybar colors now darker waybar-v0.1-dw.nix
- 📁 **File**: Changed filename to waybar-ddubs-v0.1.nix

##### 3-11-25

- ⚙️ **Yazi**: Added inout for yazi to build from source
- 💻 **Host**: Added prometheus nvidia hybrid laptop
- ⚙️ **System**: Changed system version to 24.11 OS was built on 24.11 ISOs
- 🐚 **Shell**: Added oh-my-posh powerline theme to Home Mgr
- ⚙️ **NVIDIA**: Added ENV variable
  "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1" To enable NVIDIA on hybrid
  laptop
- ⚙️ **Yazi**: Added yazi.nix to configure new yazi
- 🖼️ **Wallpapers**: Added about 800MB+ of wallpapers

##### 3-10-25

- 🔄 **System**: Updated flake
- ✅ **Envfs**: re-enabled envfs (missed after sync'ng zaneyos)
- 💬 **IM**: Added signal desktop

##### 3-9-25

- ❌ **Yazi**: Disabled Yazi override stable is 0.3.3 anyways :(
- ⌨️ **Keybinds**: Adjusted some bindings, disabled HL specialworkspace
- 🔄 **System**: Updated flake

##### 3-8-25

- ⌨️ **Keybinds**: swapped CTRL+SHIFT+S to verical split and CTRL+SHIFT+V to
  paste
- 🔀 **Git**: Added onefetch for GIT repo stats
- 🔄 **System**: Updated flake
- 📹 **Screen Capture**: Added focal screen/video capture
- 📦 **Deps**: Added slurp, grim, wl-recorder, wl-clipboard as deps for focal
- ⌨️ **Keybinds**: Added bindings for focal SUPER \ and SUPER + SHIFT \
- 📖 **Docs**: Sync'd updated FAQ.md

##### 3-7-25

- 🔀 **Merge**: Merged current Zaneyos updates to ddubs-dev-4 branch
- ⚙️ **Hosts**: updated variables.nix on all host reflex changes to default
- 🔄 **System**: Updated flake
- 🖼️ **Wallsetter**: Changed wallsetter timer to 700 for testing
- 📦 **Virtualization**: Added Distrobox
- ⌨️ **Hyprland**: Hyprland bindings moved to binds.nix
- ✅ **Fix**: Fixed menu binding to my choice SUPER +D
- 🎨 **Stylix**: Enabled stylix theming
- 🎨 **Kitty**: Added font_size 12 to kitty
- 🎨 **Ghostty**: Reduced font in ghostty
- ⌨️ **Kitty**: Added bindings to kitty config
- ✨ **Kitty**: Added top bar in kitty with powerline theme
- ✅ **Kitty**: After many failures horizonal and vertical splits work in kitty
- ⚙️ **Wezterm**: Added config (from Drew) for wezterm
- ⏰ **Timezone**: Reset TZ to New York
- ❌ **Plymouth**: Disabled plymouth
- ⚙️ **Kernel**: Installed 6.13.6 on mini-intel
- ⚙️ **Wezterm**: Set wezterm to xterm-256 to resolve compatibility issues with
  NANO and CTRL + L won't clear screen when term set to wezterm
- 🎨 **Wezterm**: Added two commented out wezterm themes AdventureTime and
  Aarvark Blue
- 📖 **Docs**: Updated FAQ.md with links for GIT and NIXOS

##### 3-6-25

- ⌨️ **Keybinds**: Changed ALT,TAB binding to binde In the older stable version
  bind works fine but it breaks in 47.2 for sure.

##### 3-5-25

- 🔄 **System**: updated flake
- 📹 **Screen Recorder**: Added gpu-screen-recorder
- 🔍 **Menu**: Added nwg-drawer as startmenu vs. rofi
- 📁 **File Manager**: Added tumbler and ffmpegthumbnailer for filemgr
- ⚙️ **Wezterm**: Added nice config for wezterm
- 📦 **Docker**: Added lazydocker
- 🗑️ **Cleanup**: Cleaned up formatting in security section, services.nix
- 🛡️ **Sudo**: Added sudo.wheelNeedsPassword = false;
- ✅ **Fix**: Fixed alias for dm and wrong PATH for doom emacs

##### 3-4-25

- 🔄 **System**: updated flake

##### 3-3-25

- 📸 **Screenshot**: Added flameshot
- ⚙️ **Host**: Updated explorer host hw
- ✅ **Fix**: Fixed bad package name in explorer package file
- 🖥️ **Display**: Added monitor settings for exploer

##### 3-2-25

- 🔄 **System**: Updated flake
- 💡 **QEMU**: Starting work to move qemu packages to virt-mgr nix file
- 📦 **Podman**: Added podman to virtualization.nix
- ⌨️ **Keybinds**: Add swapwindows with arrows and vim motions

</details>

<details>

<summary><strong>📅  February Change History</strong></summary>

##### 2-28-25

- 🔄 **System**: Updated flake
- 🎵 **Audio**: Added cava.nix with 3 color configs

##### 2-24-25

- 🗑️ **BSPWM**: Removed BSPWM programs and configs
- 🔄 **System**: Updated flake
- ⚙️ **Services**: Moved smartd service to profiles from serivces.nix.
- ⚙️ **VM**: VM profile is disabled All others enabled

##### 2-23-25

- 📁 **Template**: Added host template for explorer
- 🔄 **System**: Updated flake
- ⚙️ **System**: Updated state.SystemVersion to 24.11 since it was
- ⚙️ **System**: built with 24.11 ISOs.
- 📦 **Packages**: Adding my packages part 1
- ⚙️ **Wezterm**: Added wezterm.nix to HM
- ✅ **Fix**: Fixed wezterm.nix forgot return config
- ✨ **Wezterm**: Added sleep before fastfetch for wezterm
- ✅ **Wezterm**: Enableb wayland in wezterm
- ⌨️ **Alias**: Created alilas for doom emacs, path is there but won't start
- ⚙️ **BSPWM**: Added HM files for bspwm,polybar,picom,sxhkb
- ✅ **Fix**: Fixed bspwm.nix
- ❌ **Polybar**: disabled polybar.nix Errors on colors?

##### 2-22-25

- 🌿 **Branch**: Created ddubs-dev-3 branch to sync zaneyos
- 🔄 **Update**: Updated my changes
- ✨ **Pyprland**: Pyrpland now has thunar scratchpad
- 🐚 **Shell**: Disabled starship and enabled Oh-My-Posh
- 🐚 **Shell**: Added oh-my-posh.nix to configure OMP
- 🐚 **Shell**: Added zshrc-personal.nix to config $HOME/.zshrc-personal
- 🐚 **Shell**: Added IF statement to check then source $HOME/.zshrc-personal
- ⌨️ **Keybinds**: Added swap windows with arrows

##### 2-21-25

- ✅ **Smartd**: re-enabled smartd
- 📦 **Packages**: Added back missing packages vlc, discord-canary, ncftp
- ⚙️ **Btop**: Edited btop.conf to show process tree by default
- ⚙️ **SDL**: Changed SDL backend to wayland for doom games
- ⚙️ **Btop**: Added AMD, NVIDIA support to btop
- ⚙️ **Btop**: Added Disk IO R/W stats to btop
- ✅ **Fix**: Fixed pyprland.nix file (again) xdg.configFile
- ✅ **Fix**: Fixed pyprland.nix file (for real this time) xdg.configFile
- 📦 **Package**: Added libreoffice
- ✅ **FHS**: enabled envfs for FHS support
- 📦 **Package**: Added vscode-fhs
- ✨ **Fastfetch**: Updated fastfetch for more info and brighter text
- ✅ **Pyprland**: Enabled pyprland expose
- ⚙️ **NVIDIA**: Added NVIDIA prime variables to host files

##### 2-20-25

- 🔄 **Sync**: Updated to current zaneyos build
- ✨ **Fetch**: Added neofetch
- 🔄 **System**: Updated flake

##### 2-19-25

- ✨ **Waybar**: Adjusted waybar config
- 🔄 **System**: Updated flake
- ⚙️ **Pyprland**: Added pyrpland.nix to HM config
- ⚙️ **Ghostty**: Add ghostty config to HM
- ✅ **Fix**: Updated download buffer nix setting to remove error in NVIM

##### 2-18-25

- 🌿 **Branch**: updated ddubs dev branch
- ⌨️ **Keybinds**: modified waybar keybinds
- 📦 **Packages**: added my core programs
- 📦 **Package**: added doom emacs
- 📦 **Packages**: Added more packages
- 📦 **Package**: Added nvtop updated git username/EM
- ⚙️ **Flake**: Increased download buffer size in flake.nix
- 🆔 **NVTOP**: New NVTOP package name nvtopPackages.full

</details>
