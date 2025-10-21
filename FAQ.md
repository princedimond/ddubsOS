English | [Español](./FAQ.es.md)

# 💬 ddubsOS FAQ for v2.5.8

- **Date:** 17-September-2025

## ddubsOS related

### How do I build by host vs by profile?

- By host (new, preferred):
  - sudo nixos-rebuild switch --flake .#<host>
- By profile (legacy, still available):
  - sudo nixos-rebuild switch --flake .#<profile> # amd | intel | nvidia |
    nvidia-laptop | vm

See also: docs/upgrade-from-2.4.md

### What installer flags are available now?

- ./install-ddubsos.sh --host <name> --profile
  <amd|intel|nvidia|nvidia-laptop|vm> --build-host --non-interactive
- --host/--profile preselect values; --build-host builds the .#<host> target;
  --non-interactive accepts defaults without prompts.

### How do I add/delete/rename hosts with zcli?

- Add: zcli add-host <name> [profile]
- Delete: zcli del-host <name>
- Rename: zcli rename-host <old> <new>
- Set flake host only: zcli hostname set <name>
- Update both host and profile in flake: zcli update-host [name] [profile]

### Step-by-step: migrate a VM to host-based targets (example: ddubsos-vm)

This example assumes you have a VM currently building with legacy profile
targets (e.g., .#vm) and you want to start using the new host target while
keeping legacy available.

1. Switch to the refactor branch

- git switch ddubos-refactor

Important (v2.4 users): Do the first rebuild with nixos-rebuild, not zcli

- On Stable v2.4 the installed zcli is not refactor-aware. After switching
  branches, run one rebuild with your existing profile target to install the
  updated zcli.
  - Example: sudo nixos-rebuild switch --flake .#vm
- After that initial rebuild, you can use zcli and host-based targets.

2. Ensure a host folder exists for the VM

- If it already exists: hosts/ddubsos-vm
- If not, scaffold from the default template (and optionally pick a profile):
  - zcli add-host ddubsos-vm vm
  - Edit hosts/ddubsos-vm/variables.nix as needed (browser, terminal,
    stylixImage, etc.).

3. Point flake host/profile at this VM host

- zcli update-host ddubsos-vm vm
  - This updates host = "ddubsos-vm" and profile = "vm" in flake.nix.

4. Rebuild using the host target (new path)

- sudo nixos-rebuild switch --flake .#ddubsos-vm
  - You can still use the legacy profile too: sudo nixos-rebuild switch --flake
    .#vm

> **Note:** Hyprpanel is the default option. When you first login it will take
> 30 secs to a minute for it to load It's reading a very large JSON file.\
> SUPER + Enter to open a terminal or SUPER + D to launch app menu.

**⌨ Where can I see the Hyprland keybindings?**

- The SUPER + SHIFT + K opens the **qs-keybinds** interactive viewer with all keybindings
- Browse keybindings for Hyprland, Emacs, Kitty, WezTerm, and Yazi with real-time search
- Click any keybind to copy it to clipboard with notification
- The "keys" icon on the right side of the waybar will also bring up this menu.

<details>
<summary><strong>🖥️  ZCLI:  What is it and how do I use it?</strong></summary>
<div style="margin-left: 20px;">

The `zcli` utility (v1.1.0) is a command-line tool designed to simplify the
management of your ddubsOS environment. It provides a comprehensive set of
commands with advanced options for system management, host configuration,
maintenance tasks, Doom Emacs management, and Glances monitoring server control.

New in v1.1.0:

- Interactive staging before rebuild/update
  - Rebuild commands will list untracked/unstaged files indexed; choose numbers
    or 'all' to stage, or press Enter to skip.
  - New flags:
    - `--no-stage` to skip the prompt
    - `--stage-all` to stage everything automatically
  - New command: `zcli stage [--all]` to run the selector without rebuilding

Previously added (v1.0.4):

- Settings editing with validation, backups, and --dry-run
  - `zcli settings set <attr> <value> [--dry-run]`
  - Validates `browser`/`terminal` against supported lists; validates paths for
    `stylixImage`, `waybarChoice`, `animChoice`
  - Discoverability: `zcli settings --list-browsers`,
    `zcli settings --list-terminals`
- Hosts apps overview: `zcli hosts-apps` to list host-specific packages
- Quality-of-life: `zcli upgrade` as an alias for `zcli update`

To use it, open a terminal and type `zcli` followed by one of the commands
listed below. You can also use advanced flags for enhanced control:

### 🚀 **Core Commands:**

- `rebuild`: Rebuild the NixOS system configuration
- `rebuild-boot`: Rebuild and activate on next boot (safer for major changes)
- `update`: Update the flake and rebuild the system
- `cleanup`: Clean up old system generations (specify number to keep)
- `list-gens`: List user and system generations
- `trim`: Trim filesystems to improve SSD performance
- `diag`: Create a system diagnostic report, saved to `~/diag.txt`

### 🏠 **Host Management:**

- `update-host`: Automatically set host and profile in `flake.nix` with GPU
  detection
- **GPU Profiles**: `amd`, `intel`, `nvidia`, `nvidia-laptop`, `vm`

### ⚙️ **Advanced Options (v1.1.0):**

- `--dry, -n`: Show what would be done without executing (dry run mode)
- `--ask, -a`: Ask for confirmation before proceeding with operations
- `--cores N`: Limit build operations to N CPU cores (useful for VMs)
- `--verbose, -v`: Enable verbose output for detailed operation logs
- `--no-nom`: Disable nix-output-monitor for cleaner output
- `--no-stage`: Skip the staging prompt (do not stage anything before building)
- `--stage-all`: Stage all untracked/unstaged files automatically before
  building

### 📚 **Help:**

- `help`: Show comprehensive help message with all options

```text
ddubsOS CLI Utility -- version 1.1.0

Usage: zcli [command] [options]

Commands:
  cleanup         - Clean up old system generations. Can specify a number to keep.
  diag            - Create a system diagnostic report.
                    (Filename: homedir/diag.txt)
  list-gens       - List user and system generations.
  rebuild         - Rebuild the NixOS system configuration.
  rebuild-boot    - Rebuild and set as boot default (activates on next restart).
  trim            - Trim filesystems to improve SSD performance.
  update          - Update the flake and rebuild the system.
  stage [--all]   - Interactively stage changes (or stage all) before a rebuild.
  update-host     - Auto set host and profile in flake.nix.
                    (Opt: zcli update-host [hostname] [profile])

Options for rebuild, rebuild-boot, and update commands:
  --dry, -n       - Show what would be done without doing it
  --ask, -a       - Ask for confirmation before proceeding
  --cores N       - Limit build to N cores (useful for VMs)
  --verbose, -v   - Show verbose output
  --no-nom        - Don't use nix-output-monitor
  --no-stage      - Skip the staging prompt (do not stage anything)
  --stage-all     - Stage all untracked/unstaged files automatically before rebuild


Glances Server:
  glances start   - Start the glances monitoring server.
  glances stop    - Stop the glances monitoring server.
  glances restart - Restart the glances monitoring server.
  glances status  - Show glances server status and access URLs.
  glances logs    - Show glances server logs.

  help            - Show this help message.

~
❯

ex: 
>zcli rebuild-boot --cores 4 
>zcli rebuild
>zcli rebuild --verbose --ask
```

</div>
</details>

## Major Hyprland Keybindings

Below are the keybindings for Hyprland, formatted for easy reference.

**📂 What are the quick-select apps (qs-keybinds, qs-cheatsheets, qs-docs)?**

ddubsOS includes three powerful Qt6 QML applications for quick access to help and documentation:

### qs-keybinds (SUPER + SHIFT + K)
- **Interactive keybindings viewer** with real-time search and filtering
- **Multi-mode support**: Hyprland, Emacs, Kitty, WezTerm, Yazi, and Cheatsheets
- **Copy functionality**: Click any keybind to copy it to clipboard with notification
- **Category filtering**: Browse by application categories and submodes
- **Color-coded categories**: Visual organization with themed category badges

### qs-cheatsheets (SUPER + SHIFT + C)
- **Comprehensive cheatsheets browser** for tools and applications
- **Multi-language support**: English and Spanish documentation
- **File categories**: emacs, hyprland, kitty, wezterm, yazi, nixos
- **Real-time content viewing**: Select files and see content immediately
- **Search functionality**: Filter through cheatsheet content

### qs-docs (SUPER + SHIFT + D)
- **Technical documentation viewer** for ddubsOS documentation
- **Smart file browsing**: Reads from `~/ddubsos/docs/` directory structure
- **Architecture guides**: Detailed system documentation and development guides
- **Multi-language**: Both English and Spanish technical documentation
- **Navigation tools**: Intelligent search through documentation files

**All three apps feature:**
- Modern Qt6 QML interface with consistent design
- Hyprland window rules for floating and centering
- Keyboard shortcuts (ESC to close, arrow keys for navigation)
- Professional workflow integration

## Application Launching

- `$modifier + Return` → Launch `kitty`
- `$modifier + Shift + Return` → Launch `rofi-launcher`
- `$modifier + Shift + W` → Open `web-search`
- `$modifier + Alt + W` → Open `wallsetter`
- `$modifier + Shift + N` → Run `swaync-client -rs`
- `$modifier + W` → Launch `Google Chrome`
- `$modifier + Y` → Open `kitty` with `yazi`
- `$modifier + E` → Open `emopicker9000`
- `$modifier + S` → Take a screenshot
- `$modifier + D` → Open `Discord`
- `$modifier + O` → Launch `OBS Studio`
- `$modifier + C` → Run `hyprpicker -a`
- `$modifier + G` → Open `GIMP`
- `$modifier + V` → Show clipboard history via `cliphist`
- `$modifier + T` → Toggle terminal with `pypr`
- `$modifier + M` → Open `pavucontrol`

## Window Management

- `$modifier + Q` → Kill active window
- `$modifier + P` → Toggle pseudo tiling
- `$modifier + Shift + I` → Toggle split mode
- `$modifier + F` → Toggle fullscreen
- `$modifier + Shift + F` → Toggle floating mode
- `$modifier + Alt + F` → Toggle Fullscreen 1
- `$modifier + SPACE` → Float current window
- `$modifier + Shift + SPACE` → Float all windows

## Window Movement

- `$modifier + Shift + ← / → / ↑ / ↓` → Move window left/right/up/down
- `$modifier + Shift + H / L / K / J` → Move window left/right/up/down
- `$modifier + Alt + ← / → / ↑ / ↓` → Swap window left/right/up/down
- `$modifier + Alt + 43 / 46 / 45 / 44` → Swap window left/right/up/down

## Focus Movement

- `$modifier + ← / → / ↑ / ↓` → Move focus left/right/up/down
- `$modifier + H / L / K / J` → Move focus left/right/up/down

## Workspaces

- `$modifier + 1-10` → Switch to workspace 1-10
- `$modifier + Shift + Space` → Move window to special workspace
- `$modifier + Space` → Toggle special workspace
- `$modifier + Shift + 1-10` → Move window to workspace 1-10
- `$modifier + Control + → / ←` → Switch workspace forward/backward

## Window Cycling

- `Alt + Tab` → Cycle to next window
- `Alt + Tab` → Bring active window to top

</details>

<details>
<summary><strong>❄ Why did you create ddubsOS ? </strong></summary>

<div style="margin-left: 20px;">

- I was interested in NixOS but lost where to start.
- I found the ZaneyOS project and it provided a stable, working configuration.
- Like ZaneyOS, ddubsOS is not intended as a distro.
- It's my working configuration, I am sharing it out `as-is`.
- ddubsOS has features that didn't fit with Zaney's design.
- The `ZaneyOS` name is an inside joke among friends.
- So I named my fork "ddubsOS".
- The intent is this configuration can be used as a daily driver
- Develop software, play games via steam, etc.
- My hope is that it helpful, and will modify it to fit your needs.
- That is the key take away. Make it your own.
- You create a fork of ddubsOS, then modify it.
- If you find an issue and fix it, or provide a new feature, please share it.
- dduybsOS/ZaneyOS are not distros. At this time there are no plans to create an
  install ISO.

</div>
</details>

<details>
<summary><strong>🖼️ Settings and configuration</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary><strong>💫 How do I change the Starship prompt?</strong></summary>

- Go to `~/ddubsOS/hosts/HOSTNAME/`
- Edit `variables.nix`
- Find the line starting with `starshipChoice`
- Set it to one of the available prompt configs and rebuild with `zcli rebuild`

Available options:

- `../../modules/home/cli/starship.nix` (default)
- `../../modules/home/cli/starship-1.nix`
- `../../modules/home/cli/starship-rbmcg.nix`

Example:

```nix path=null start=null
# Set Starship prompt
starshipChoice = ../../modules/home/cli/starship.nix;
#starshipChoice = ../../modules/home/cli/starship-1.nix;
#starshipChoice = ../../modules/home/cli/starship-rbmcg.nix;
```

</details>

<div style="margin-left: 20px;">

<details>
<summary><strong>🌐 How to I change the waybar?</strong></summary>

- 📂 Go to the `~/ddubsos/hosts/HOSTNAME/`
- ✏️ Edit the `variables.nix` file
- 🔎 Find the line that starts `waybarChoice`
- 🔄 Change the name to one of the available files
- `waybar-simple.nix`, `waybar-nerodyke.nix`, `waybar-curved.nix`, or
  `waybar-ddubs.nix`
- 💾 Save the file and exit
- ⚡ You need to do a rebuild to make the change effective
- Run `fr` "flake rebuild" to start the rebuild process

```json
# Set Waybar
# Includes alternates such as waybar-simple.nix, waybar-curved.nix & waybar-ddubs.nix
waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
```

</details>

<details>
<summary><strong>🎛️ How do I switch between HyprPanel and Waybar?</strong></summary>

- 📂 Go to `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edit the `variables.nix` file
- 🔎 Find the line that starts `panelChoice`
- 🔄 Change the value to either `"hyprpanel"` or `"waybar"`
- 💾 Save the file and exit
- ⚡ Rebuild with `zcli rebuild` to apply changes

```nix
# Panel Choice - set to "hyprpanel" or "waybar"
panelChoice = "hyprpanel";
# or
panelChoice = "waybar";
```

**Available Options:**

- `"hyprpanel"` - Modern panel with advanced features and widgets
- `"waybar"` - Traditional bar with customizable modules

</details>

<details>
<summary><strong>📊 How do I enable the Glances monitoring server?</strong></summary>

- 📂 Go to `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edit the `variables.nix` file
- 🔎 Find the line `enableGlances = false;`
- ✅ Change it to `enableGlances = true;`
- 💾 Save the file and exit
- ⚡ Rebuild with `zcli rebuild` to apply changes
- 🌐 Access the web interface at `http://localhost:61210`

```nix
# Glances Server - set to true to enable glances web server
enableGlances = true;
```

**Features:**

- 📈 Real-time system monitoring dashboard
- 🌐 Web interface accessible from any device on your network
- 📊 CPU, memory, disk, network, and process monitoring
- 🛠️ Management commands: `glances-server start/stop/restart/status`

</details>

<details>
<summary><strong>📝 How do I enable VSCode or Helix?</strong></summary>

- 📂 Go to `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edit the `variables.nix` file
- 🔎 Find the "Editor Options" section
- ✅ Change the desired editor from `false` to `true`
- 💾 Save the file and exit
- ⚡ Rebuild with `zcli rebuild` to apply changes

```nix
# Editor Options - set to true to enable
enableEvilhelix = true;   # Enable evil-helix (Helix with Vim-style keybindings)
enableVscode = false;     # Keep VSCode disabled
```

**Available Editor Options:**

- `enableEvilhelix` - Evil Helix editor with Vim-style keybindings and modern
  features
- `enableVscode` - Visual Studio Code with extensions and customizations

**Notes:**

- Both editors are disabled by default to keep the system minimal
- You can enable both editors on the same host if desired
- Doom Emacs and Neovim are always available and don't need these variables

</details>

<details>
<summary><strong>🖥️ How do I enable/disable optional terminals?</strong></summary>

- 📂 Go to `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edit the `variables.nix` file
- 🔎 Find the "Terminal Options" section
- ✅ Change the desired terminal from `false` to `true`
- 💾 Save the file and exit
- ⚡ Rebuild with `zcli rebuild` to apply changes

```nix
# Terminal Options - set to true to enable
enableAlacritty = true;   # Enable Alacritty GPU-accelerated terminal
enableTmux = false;       # Enable Tmux terminal multiplexer
enablePtyxis = false;     # Enable Ptyxis GNOME terminal
```

**Available Terminal Options:**

- `enableAlacritty` - Fast GPU-accelerated terminal emulator written in Rust
- `enableTmux` - Terminal multiplexer for managing multiple terminal sessions
- `enablePtyxis` - Modern GNOME terminal emulator with advanced features

**Core Terminals (Always Available):**

- **Ghostty** - Modern terminal with excellent performance and features
- **Kitty** - GPU-based terminal emulator with advanced graphics support
- **Foot** - Lightweight Wayland terminal emulator
- **WezTerm** - GPU-accelerated cross-platform terminal emulator

**Notes:**

- Optional terminals are disabled by default to keep the system minimal
- You can enable multiple terminals on the same host if desired
- Core terminals are always available and don't require these variables
- Enabling terminals only affects the packages installed, not system behavior

</details>

<details>
<summary><strong>🖥️ How do I enable the optional DE/WM GUIs?</strong></summary>

- 📂 Go to `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edit the `variables.nix` file
- 🔎 Find the "Desktop Environment Options" section
- ✅ Change the desired DE/WM from `false` to `true`
- 💾 Save the file and exit
- ⚡ Rebuild with `zcli rebuild` to apply changes

```nix
# Desktop Environment Options - set to true to enable
gnomeEnable = false;      # GNOME desktop environment
bspwmEnable = true;       # BSPWM tiling window manager
dwmEnable = false;        # DWM suckless window manager
wayfireEnable = false;    # Wayfire Wayland compositor
```

**Available Desktop Environment Options:**

- `gnomeEnable` - Full GNOME desktop environment with all applications and
  services
- `bspwmEnable` - Binary Space Partitioning Window Manager (lightweight tiling
  WM)
- `dwmEnable` - Dynamic Window Manager from suckless tools (minimal tiling WM)
- `wayfireEnable` - Wayfire Wayland compositor with effects and plugins

**Notes:**

- All desktop environments are disabled by default (Hyprland is the primary DE)
- Only enable one desktop environment at a time to avoid conflicts
- These are additional options alongside the default Hyprland configuration
- Each DE/WM comes with its own set of applications and configurations

</details>

<details>
<summary><strong>🕒 How do I change the Timezone? </strong></summary>

1. In the file, `~/ddubsOS/modules/core/system.nix`
2. Edit the line: time.timeZone = "America/New_York";
3. Save the file and rebuild using the `fr` alias.

</details>

<details>
<summary><strong>🖥️ How do I change the monitor settings? </strong></summary>

Monitor settings live in: `~/ddubsOS/hosts/<HOSTNAME>/variables.nix`

As of the monitorv2 migration, use the structured `hyprMonitorsV2` list at the
bottom of that file. Legacy `extraMonitorSettings` (string with `monitor = ...`)
is still supported for compatibility and examples, but v2 is preferred.

Quick steps

- Find the hyprMonitorsV2 block at the bottom of your host's variables.nix
- Add or edit outputs there
- Rebuild: `zcli rebuild` (or `fr` alias)
- Verify: `hyprctl monitors`

Single monitor (v2)

```nix
hyprMonitorsV2 = [
  {
    output = "eDP-1";
    mode = "1920x1080@60";
    position = "0x0";   # or "auto"
    scale = 1;
    enabled = true;      # set false to disable
  }
];
```

Dual monitors side-by-side (v2)

```nix
hyprMonitorsV2 = [
  {
    output = "DP-1";
    mode = "2560x1440@144";
    position = "0x0";
    scale = 1;
    transform = 0;       # 0=normal, 1=90, 2=180, 3=270, 4..7=flipped variants
    enabled = true;
  }
  {
    output = "HDMI-A-1";
    mode = "1920x1080@60";
    position = "2560x0"; # to the right of DP-1
    scale = 1.25;
    transform = 0;
    enabled = true;
  }
];
```

Mirroring example (v2)

```nix
hyprMonitorsV2 = [
  { output = "eDP-1"; mode = "1920x1080@60"; position = "0x0"; scale = 1; enabled = true; }
  { output = "HDMI-A-1"; mirror = "eDP-1"; enabled = true; }
];
```

Notes

- enabled toggles an output without removing its block
- transform values: 0=normal, 1=90, 2=180, 3=270, 4=flipped, 5=flipped-90,
  6=flipped-180, 7=flipped-270
- Legacy string remains available at the bottom of variables.nix (commented);
  VMs include a Virtual-1 default

Discovering names and modes

- Run `hyprctl monitors` to list outputs, available modes, current
  scale/transform, etc.

GUI helper (optional)

- Tools like `nwg-displays` can still help you discover arrangements; copy
  settings into hyprMonitorsV2 afterward

More details: see docs/outline-move-monitorsv2-way-displays.md and the Hyprland
Monitors page.

</details>

<details>
<summary><strong>🚀 How do I add applications to ddubsOS? </strong></summary>

### There are two options. One for all hosts you have, another for a specific host.

1. For applications to be included in all defined hosts edit the
   `~/ddubsOS/modules/core/packages.nix` file.

There is a section that begins with: `environment.systemPackages = with pkgs;`

Followed by a list of packages These are required for ddubsOS.

We suggest you add a comment at the end of the package names. Then add in your
packages.

```text
    ...
    virt-viewer
    wget
    ###  My Apps ### 
    bottom
    dua
    emacs-nox
    fd
    gping
    lazygit
    lunarvim
    luarocks
    mission-center
    ncdu
    nvtopPackages.full
    oh-my-posh
    pyprland
    shellcheck
    multimarkdown
    nodejs_23
    ugrep
    zoxide
  ];
}
```

2. For applications that will only be on specific host.

You edit the `host-packages.nix` associated with that host.
`~/ddubsOS/hosts/<HOSTNAME>/host-packages.nix`

The part of the file you need to edit, looks like this:

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    audacity
    discord
    nodejs
    obs-studio
  ];
}
```

You can add additional packages, or for example change `discord` to
`discord-canary` to get the beta version of Discord but only on this host.

</details>

<details>

<summary><strong>📥 I added the package names, now how do I install them ? </strong></summary>

- Use the `fr`, Flake Rebuild alias.

If the rebuild completes successfully, a new generation with your added packages
will be created.

</details>

<details>
<summary><strong>🔄 How do I update the packages I've already installed? </strong></summary>

- Use the `fu`, Flake Update alias. This will check for updated packages,
  download and install them.

</details>

<details>
<summary><strong>⚙️ I made a change to my ddubsOS configuration, how do I activate it? </strong></summary>

- Use the `fr` Flake Rebuild alias. If you **created a new file** please note
  you will need to run a `git add .` command in the ddubsOS folder. If
  successful, a new generation will be generated with your changes. A logout or
  reboot could be required depending on what you changed.

</details>

<details>

<summary><strong>🔠 What fonts are available in NixOS</strong></summary>

```nix
{pkgs, ...}: {
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
      # NERD fonts 
      nerd-fonts.0xproto
      nerd-fonts._3270
      nerd-fonts.agave
      nerd-fonts.anonymice
      nerd-fonts.arimo
      nerd-fonts.aurulent-sans-mono
      nerd-fonts.bigblue-terminal
      nerd-fonts.bitstream-vera-sans-mono
      nerd-fonts.blex-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.code-new-roman
      nerd-fonts.comic-shanns-mono
      nerd-fonts.commit-mono
      nerd-fonts.cousine
      nerd-fonts.d2coding
      nerd-fonts.daddy-time-mono
      nerd-fonts.departure-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.droid-sans-mono
      nerd-fonts.envy-code-r
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.geist-mono
      nerd-fonts.go-mono
      nerd-fonts.gohufont
      nerd-fonts.hack
      nerd-fonts.hasklug
      nerd-fonts.heavy-data
      nerd-fonts.hurmit
      nerd-fonts.im-writing
      nerd-fonts.inconsolata
      nerd-fonts.inconsolata-go
      nerd-fonts.inconsolata-lgc
      nerd-fonts.intone-mono
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      nerd-fonts.jetbrains-mono
      nerd-fonts.lekton
      nerd-fonts.liberation
      nerd-fonts.lilex
      nerd-fonts.martian-mono
      nerd-fonts.meslo-lg
      nerd-fonts.monaspace
      nerd-fonts.monofur
      nerd-fonts.monoid
      nerd-fonts.mononoki
      nerd-fonts.mplus
      nerd-fonts.noto
      nerd-fonts.open-dyslexic
      nerd-fonts.overpass
      nerd-fonts.profont
      nerd-fonts.proggy-clean-tt
      nerd-fonts.recursive-mono
      nerd-fonts.roboto-mono
      nerd-fonts.shure-tech-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.space-mono
      nerd-fonts.symbols-only
      nerd-fonts.terminess-ttf
      nerd-fonts.tinos
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.victor-mono
      nerd-fonts.zed-mono

    ];
  };
}
```

</details>

<details>
<summary><strong>🐧 How can I configure a different kernel on a specific host? </strong></summary>

1. You have to edit the `hardware.nix` file for that host in
   `~/ddubsOS/hosts/HOSTNAME/hardware.nix` and override the default.
2. Near the top you will find this section of the `hardware.nix` file.

```nix
boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
boot.initrd.kernelModules = [];
boot.kernelModules = ["kvm-intel"];
boot.extraModulePackages = [];
```

3. Add the override. E.g. to set the kernel to 6.12.

- `boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;`

4. The updated code should look like this:

```nix
boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;
boot.initrd.kernelModules = [];
boot.kernelModules = ["kvm-intel"];
boot.extraModulePackages = [];
```

5. Use the command alias `fr` to create a new generation and reboot to take
   effect.

</details>

<details>

<summary><strong>🐧 What are the major Kernel options in NixOS? </strong></summary>
NixOS offers several major kernel types to cater to different needs and preferences. Below are the available options, excluding specific kernel versions:

1. **`linuxPackages`**
   - The default stable kernel, typically an LTS (Long-Term Support) version.
     LTS in 25.05 (warbler) is 6.12.x Older kernels, 6.6.x, 6.8.x are not
     supported.

2. **`linuxPackages_latest`**
   - The latest mainline kernel, which may include newer features but could be
     less stable.

3. **`linuxPackages_zen`**
   - A performance-optimized kernel with patches aimed at improving
     responsiveness and interactivity. Commonly used by gamers and desktop
     users.

4. **`linuxPackages_hardened`**
   - A security-focused kernel with additional hardening patches for enhanced
     protection.

5. **`linuxPackages_rt`**
   - A real-time kernel designed for low-latency and time-sensitive
     applications, such as audio production or robotics.

6. **`linuxPackages_libre`**
   - A kernel stripped of proprietary firmware and drivers, adhering to free
     software principles.

7. **`linuxPackages_xen_dom0`**
   - A kernel tailored for running as the host (dom0) in Xen virtualization
     environments.

8. **`linuxPackages_mptcp`**
   - A kernel with support for Multipath TCP, useful for advanced networking
     scenarios.

</details>

</details>

<details>
<summary><strong>📷 v4l2loopback fails to build with CachyOS kernel (clang). How do I fix it?</strong></summary>

- Symptom: gcc not found or clang unused-argument errors when building
  v4l2loopback against the Cachy/clang kernel; install phase may try to build a
  userspace ctl and fail.
- Fix: ddubsOS forces an LLVM toolchain for the module build and installs only
  the kernel module, skipping the ctl. See the full write-up and exact override
  in:
  - docs/Cachy-kernel-v4l2loopback-build-issues.md

</details>

<details>
<summary><strong>🗑️  I have older generations I want to delete, how can I do that? </strong></summary>

- The `ncg` NixOS Clean Generations alias will remove **ALL** but the most
  current generation. Make sure you have booted from that generation before
  using this alias. There is also a schedule that will remove older generations
  automatically over time.

</details>

</details>

<details>
<summary><strong>📝 How do I change the hostname? </strong></summary>

To change the hostname, there are several steps and you will have to reboot to
make the change effective.

1. Copy the directory of the host you want to rename to a directory with the new
   name.

- `cp -rpv ~/ddubsOS/hosts/OLD-HOSTNAME ~/ddubsOS/hosts/NEW-HOSTNAME`

2. Edit the `~/ddubsOS/flake.nix` file. Change the line:

- `host = "NEW-HOSTNAME"`

3. In the `~/ddubsOS` Directory run `git add .` _The rebuild will fail with a
   'file not found' error if you forget this step._

4. Use the `fr` alias to create a new generation with the new hostname. You must
   reboot to make the change effective.

</details>
</details>

<details>
<summary><strong>❄️ How do I disable the spinning snowflake at startup? </strong></summary>

1. Edit the `~/ddubsOS/modules/core/boot.nix` file.
2. Look for:

```nix
};
 plymouth.enable = true;
};
```

3. Change it to `false`
4. Run the command alias `fr` to create a new generation.

</details>

</details>

<details>
<summary><strong>💻 How do I configure my hybrid laptop with Intel/NVIDIA GPUs?  </strong></summary>
1. Either run the `install-ddubsOS.sh` script and select `nvidia-laptop`
   template or if configuring manually, set the template in the `flake.nix` to
   `nvidia-prime`

2. In the `~/ddubsOS/hosts/HYBRID-HOST/variables.nix` file you will need to set
   the PCI IDs for the Intel and NVIDIA GPUs. Refer to
   [this page](https://nixos.wiki/wiki/Nvidia) to help determine those values.

3. Once you have everything configured properly, use the `fr` Flake Rebuild
   alias to create a new generation.

4. In the `~/ddubsOS/modules/home/hyprland/config.nix` file is an ENV
   setting`"AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"` This sets the primary
   and secondary GPUs. Using the info from the weblink above you might have to
   change the order of these values.

</details>

<details>
<summary><strong>🤖 OpenWebUI + Ollama - AI/LLM Infrastructure</strong></summary>

**Available on NVIDIA systems only** - This AI/LLM infrastructure provides local
language model inference with a modern web interface.

### 🚀 **Quick Start**

1. **Access the Web Interface**
   - Open your browser and go to `http://localhost:3000`
   - The interface will be available after system rebuild on NVIDIA hosts

2. **Download Your First Model**
   - In OpenWebUI, click "Models" → "Pull a model from Ollama.com"
   - Try starting with `llama3.2:1b` for a lightweight model
   - Or use the command line: `ollama-webui-manager models`

### 📊 **Management Script Usage**

The `ollama-webui-manager` command provides comprehensive control:

```bash
# Check system status
ollama-webui-manager status

# Service control
ollama-webui-manager start     # Start services
ollama-webui-manager stop      # Stop services  
ollama-webui-manager restart   # Restart services

# Log monitoring
ollama-webui-manager logs           # View both service logs
ollama-webui-manager logs ollama    # Just Ollama logs
ollama-webui-manager logs webui     # Just OpenWebUI logs

# Model management
ollama-webui-manager models    # List downloaded models

# Health checks
ollama-webui-manager test      # Test API connectivity

# Help and documentation
ollama-webui-manager help      # Show all commands
```

### 🌐 **Access Points**

- **OpenWebUI Web Interface**: `http://localhost:3000`
  - Modern chat interface for interacting with AI models
  - Model management and configuration
  - Chat history and conversation management

- **Ollama API**: `http://localhost:11434`
  - Direct API access for programmatic use
  - REST endpoints for model inference
  - Integration with development tools

### 🎯 **Configuration Options**

The service can be customized in your NixOS configuration:

```nix
# In profiles/nvidia/default.nix or profiles/nvidia-laptop/default.nix
services.openwebui-ollama = {
  enable = true;
  openwebuiPort = 3000;    # Web interface port (default: 3000)
  ollamaPort = 11434;      # API port (default: 11434)
  dataDir = "/var/lib/openwebui-ollama";  # Data storage location
  user = "openwebui";      # Service user (default: openwebui)
  group = "openwebui";     # Service group (default: openwebui)
};
```

### 🛠️ **Advanced Usage**

**Direct Docker Commands** (if needed):

```bash
# Pull models directly
docker exec ollama ollama pull llama3.2:1b

# List running containers
docker ps | grep -E "(ollama|openwebui)"

# Check container logs
docker logs ollama
docker logs openwebui
```

**SystemD Service Management**:

```bash
# Check service status
sudo systemctl status ollama-docker.service
sudo systemctl status openwebui-docker.service

# Manual restart (use management script instead)
sudo systemctl restart ollama-docker.service
sudo systemctl restart openwebui-docker.service
```

### 📁 **Data Location**

- **Models**: `/var/lib/openwebui-ollama/ollama/`
- **OpenWebUI Data**: `/var/lib/openwebui-ollama/openwebui/`
- **Configuration**: Managed through NixOS configuration files

### ⚡ **Performance Tips**

1. **Model Selection**: Start with smaller models (1B-3B parameters) for testing
2. **GPU Memory**: Monitor VRAM usage with `nvidia-smi` when running large
   models
3. **Storage**: Models can be large (1GB-50GB+), ensure adequate disk space
4. **Network**: Initial model downloads require good internet connection

### 🔧 **Troubleshooting**

**Services won't start:**

```bash
# Check status and logs
ollama-webui-manager status
ollama-webui-manager logs

# Test connectivity
ollama-webui-manager test

# Restart services
ollama-webui-manager restart
```

**Models not loading:**

- Ensure sufficient VRAM available
- Check disk space for model storage
- Verify model download completed successfully

**Web interface not accessible:**

- Confirm services are running: `ollama-webui-manager status`
- Check firewall allows port 3000
- Try accessing `http://localhost:3000` directly

### 📖 **Popular Models to Try**

#### **For 4GB GPUs (GTX 1650, RTX 3050, etc.)**

| Model            | Size   | Use Case                            |
| ---------------- | ------ | ----------------------------------- |
| `llama3.2:1b`    | ~1GB   | Fast, lightweight chat              |
| `llama3.2:3b`    | ~3GB   | Better quality, still fast          |
| `phi3:mini`      | ~2GB   | Microsoft's efficient model         |
| `phi3:3.8b`      | ~2.3GB | Upgraded Phi3 with better reasoning |
| `qwen2:1.5b`     | ~1GB   | Alibaba's lightweight model         |
| `gemma:2b`       | ~1.4GB | Google's small but capable model    |
| `tinyllama:1.1b` | ~637MB | Ultra-lightweight for basic tasks   |
| `orca-mini:3b`   | ~1.9GB | Good for Q&A and reasoning          |

#### **For 6GB GPUs (GTX 1660, RTX 3060, RTX 4060, etc.)**

| Model                  | Size   | Use Case                                |
| ---------------------- | ------ | --------------------------------------- |
| `llama3.2:3b`          | ~3GB   | Meta's latest efficient model           |
| `mistral:7b`           | ~4.1GB | General purpose, high quality           |
| `codellama:7b`         | ~3.8GB | Code generation and programming help    |
| `phi3:medium`          | ~7.9GB | ⚠️ _May require quantization_           |
| `neural-chat:7b`       | ~3.8GB | Intel's fine-tuned conversational model |
| `zephyr:7b-beta`       | ~4.1GB | Instruction-following model             |
| `vicuna:7b`            | ~3.8GB | Strong conversational abilities         |
| `orca-mini:7b`         | ~3.8GB | Microsoft's reasoning-focused model     |
| `starling-lm:7b-alpha` | ~4.1GB | High-quality chat model                 |
| `openhermes:7b`        | ~3.8GB | Good for creative and analytical tasks  |

#### **Memory Usage Tips**

- **Quantized models** (ending in `-q4` or `-q8`) use less VRAM but may have
  slightly reduced quality
- **Leave 1-2GB VRAM free** for system overhead and context processing
- **Monitor usage** with `nvidia-smi` while running models
- **Try smaller context windows** if you encounter out-of-memory errors

**Note**: This feature is automatically available on hosts using `nvidia` or
`nvidia-laptop` profiles after rebuilding your system with `zcli rebuild`.

</details>

</div>

</details>

<details>
<summary><strong>🎨 Stylix</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary>How do I enable or disable Stylix? </summary>

- To Enable:

1. Edit the `~/ddubsOS/modules/core/stylix.nix` file.
2. Comment out from `base16Scheme` to the `};` after `base0F`

```nix
# Styling Options
  stylix = {
    enable = true;
    image = ../../wallpapers/Anime-girl-sitting-night-sky_1952x1120.jpg;
    #image = ../../wallpapers/Rainnight.jpg;
    #image = ../../wallpapers/zaney-wallpaper.jpg;
    #  base16Scheme = {
    #  base00 = "282936";
    #  base01 = "3a3c4e";
    #  base02 = "4d4f68";
    #  base03 = "626483";
    #  base04 = "62d6e8";
    #  base05 = "e9e9f4";
    #  base06 = "f1f2f8";
    #  base07 = "f7f7fb";
    #  base08 = "ea51b2";
    #  base09 = "b45bcf";
    #  base0A = "00f769";
    #  base0B = "ebff87";
    #  base0C = "a1efe4";
    #  base0D = "62d6e8";
    #  base0E = "b45bcf";
    #  base0F = "00f769";
    #};
    polarity = "dark";
    opacity.terminal = 1.0;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
```

3. Select the image you want stylix to use for the colorpalette.
4. Run `fr` command alias to create a new generation with this colorscheme.

- To disable uncomment

1. Edit the `~/ddubsOS/modules/core/stylix.nix` file.
2. Uncomment out from `base16Scheme` to the `};` after `base0F`

```nix
 base16Scheme = {
  base00 = "282936";
  base01 = "3a3c4e";
  base02 = "4d4f68";
  base03 = "626483";
  base04 = "62d6e8";
  base05 = "e9e9f4";
  base06 = "f1f2f8";
  base07 = "f7f7fb";
  base08 = "ea51b2";
  base09 = "b45bcf";
  base0A = "00f769";
  base0B = "ebff87";
  base0C = "a1efe4";
  base0D = "62d6e8";
  base0E = "b45bcf";
  base0F = "00f769";
};
```

3. Run the `fr`command alias to build a new generation with either the default
   dracula or set your own custom colors

</details>

<details>
 <summary>How do I change the image Stylix uses to theme with?</summary>

1. Edit the `~/ddubsOS/hosts/HOSTNAME/varibles.nix`
2. Change the `stylixImage =` to the filename you want to use. Wallpapers are in
   `~/ddubsOS/wallpapers`

```nix
# Set Stylix Image
stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
```

</details>

</div>

</details>

<details>
<summary><strong>🌃 Wallpapers</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary><strong>  How do I add more wallpapers? </strong></summary>

- Wallpapers are stored in the `~/ddubsOS/wallpapers` directory.
- Simply copy the new ones to that diretory.

</details>

<details>

<summary><strong> How do I change the background? </strong></summary>

- SUPER + ALT + W will select a new background
- You can also use `waypaper` to select wallpapers or select another folder

</details>

<details>

<summary><strong>  How can I set a timer to change the wallpaper automatically?  </strong></summary>

1. Edit the `~/ddubsOS/modules/home/hyprland/config.nix` file.
2. Comment out the line `sleep 1.5 && swww img ...`
3. Add new line after that with `sleep 1 && wallsetter`

```json
settings = {
     exec-once = [
       "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
       "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
       "killall -q swww;sleep .5 && swww init"
       "killall -q waybar;sleep .5 && waybar"
       "killall -q swaync;sleep .5 && swaync"
       "nm-applet --indicator"
       "lxqt-policykit-agent"
       "pypr &"
       #"sleep 1.5 && swww img /home/${username}/Pictures/Wallpapers/zaney-wallpaper.jpg"
       "sleep 1 && wallsetter"
     ];
```

4. Run the command alias `fr` to create a new generation.
5. You will need to logout or reboot to make the change effective.

</details>

<details>

<summary><strong>How do I change the interval the wallpaper changes?  </strong></summary>

1. Edit the `~/ddubsOS/modules/home/scripts/wallsetter`
2. Change the `TIMEOUT =` value. Which is in seconds.
3. Run the command alias `fr` to create a new generation.
4. You will need to logout or reboot to make the change effective.

</details>

</div>

</details>

<details>
<summary><strong>⬆ How do I update ddubsOS?  </strong></summary>

<div style="margin-left: 20px;">

<details>
<summary> For versions v1.0+ </summary>

1. First backup your existing `ddubsOS` directory.

- `cp -rpv ~/ddubsOS ~/Backup-ZaneyOS`

_Any changes you made to the ddubsOS config will need to be re-done_

2. In the `ddubsOS` directory run `git stash && git pull`

3. Copy back your previously created host(s).

- `cp -rpv ~/Backup-ZaneyOS/hosts/HOSTNAME  ~/ddubsOS/hosts`

4. If you did not use the `default` host during your initial install

- Then do not copy the `default` host from your backup. The new default host
  might have updates or fixes you will need for the next host you create.**
- Then you will have to manually compare your backup to the new updated
  `default` host template, and potentially merge the changes and overwrite your
  `hardware.nix` file to the `~/ddubsOS/hosts/default/hardware.nix` file.**

5. In the `ddubsOS` directory run `git add .` when you have finished copying
   your host(s).

6. For any other changes you've made. For example: hyprland keybinds, waybar
   config, if you added additional packages to the `modules/packages.nix` file.
   Those you will have to manually merge back into the new version.

</details>

</div>

</details>

</div>

<details><summary><strong>📂 ddubsOS v2.x Layout</strong></summary>

<div style="margin-left: 25px;">

#### 📂 ~/ddubsOS

```text
 .
├──  cheatsheets                  # Cheatsheets and quick refs
├──  docs                         # Project docs and guides
├──  features                     # zcli feature modules (sourced at runtime)
│   ├── diag.sh
│   ├── doom.sh
│   ├── generations.sh
│   ├── glances.sh
│   ├── hosts.sh
│   ├── rebuild.sh
│   ├── settings.sh
│   └── trim.sh
├──  hosts                        # Per-host configs
│   ├── asus
│   ├── bubo
│   ├── ddubsos-vm
│   ├── default                    # Template for new hosts
│   ├── explorer
│   ├── ixas
│   ├── macbook
│   ├── mini-intel
│   ├── pegasus
│   ├── prometheus
│   └── xps15
├──  img                          # Images used in docs
├──  lib                          # zcli shared libraries
│   ├── args.sh
│   ├── common.sh
│   ├── nix.sh
│   ├── sys.sh
│   └── validate.sh
├──  modules                      # NixOS/Home Manager modules
│   ├──  core
│   ├──  drivers
│   └── 󱂵 home
│       ├──  cli
│       ├──  editors
│       ├──  gui
│       ├──  hyprland
│       ├──  hyprpanel
│       ├──  scripts              # includes zcli.nix (dispatcher)
│       ├──  shells
│       ├──  terminals
│       ├──  waybar
│       ├──  wlogout
│       ├──  yazi
│       └──  zsh
├──  myscripts-repo               # Personal scripts
├──  profiles                     # Hardware/GPU profiles
├──  wallpapers                   # Wallpaper repository
├── flake.nix
└── flake.lock
```

</div>

</details>

## 🧰 Miscellaneous

<details>
<summary><strong>📚 What is the difference between Master and Dwindle layouts</strong></summary>

<div style="margin-left: 20px;">
<br>

**1. Master Layout**

- The **Master** layout divides the workspace into two main areas:
  - A **master area** for the primary window, which takes up a larger portion of
    the screen.
  - A **stack area** for all other windows, which are tiled in the remaining
    space.
- This layout is ideal for workflows where you want to focus on a single main
  window while keeping others accessible.

**2. Dwindle Layout**

- The **Dwindle** layout is a binary tree-based tiling layout:
  - Each new window splits the available space dynamically, alternating between
    horizontal and vertical splits.
  - The splits are determined by the aspect ratio of the parent container (e.g.,
    wider splits horizontally, taller splits vertically).
- This layout is more dynamic and evenly distributes space among all windows.

---

**How to Verify the Current Layout**

To check which layout is currently active, use the `hyprctl` command:

`hyprctl getoption general:layout`

</details>
</div>

</details>

<details>
<summary><strong>📦 What are the Yazi keybindings and how can I change them? </strong></summary>

<div style="margin-left: 20px;"> <br>

The Yazi configuration file is located in `~/ddubsos/modules/home/yazi.nix`

Yazi is configured like VIM and VIM motions

The keymap is in the `~/ddubsos/modules/home/yazi/keymap.toml` file

</div>
</details>

<details>

<summary><strong>❄ Error starting Yazi ? </strong></summary>

<div style="margin-left: 20px;">

```text
yazi
Error: Lua runtime failed

Caused by:
    runtime error: [string "git"]:133: attempt to index a nil value (global 'THEME')
    stack traceback:
        [C]: in metamethod 'index'
        [string "git"]:133: in function 'git.setup'
        [C]: in method 'setup'
        [string "init.lua"]:2: in main chunk
    stack traceback:
        [C]: in method 'setup'
        [string "init.lua"]:2: in main chunk
```

- To resolve run `ya pack -u` in a terminal. Restart `yazi`

</div>
</details>

## 🖥️ Terminals

<details>
<summary><strong>🐱  Kitty</strong></summary>

<details>

<summary>My cursor in Kitty is "janky" and it jumps around. How do I fix that?</summary>

- That feature is called "cursor_trail" in the
  `~/ddubsOS/modules/home/kitty.nix` file.

1. Edit that file and change the `cursor_trail 1` to `cursor_trail 0` or comment
   out that line.
2. Use the command alias `fr` to create a new generation with the change.

</details>

<details>
 <summary>What are the Kitty keybindings and how can I change them?</summary>

The kitty bindings are configured in `~/ddubsOS/modules/home/kitty.nix`

The defaults are:

```text
    # Clipboard
    map ctrl+shift+v        paste_from_selection
    map shift+insert        paste_from_selection

    # Scrolling
    map ctrl+shift+up        scroll_line_up
    map ctrl+shift+down      scroll_line_down
    map ctrl+shift+k         scroll_line_up
    map ctrl+shift+j         scroll_line_down
    map ctrl+shift+page_up   scroll_page_up
    map ctrl+shift+page_down scroll_page_down
    map ctrl+shift+home      scroll_home
    map ctrl+shift+end       scroll_end
    map ctrl+shift+h         show_scrollback

    # Window management
    map alt+n               new_window_with_cwd      #Opens new window in current directory
    #map alt+n               new_os_window           #Opens new window in $HOME dir
    map alt+w               close_window
    map ctrl+shift+enter    launch --location=hsplit
    map ctrl+shift+s        launch --location=vsplit
    map ctrl+shift+]        next_window
    map ctrl+shift+[        previous_window
    map ctrl+shift+f        move_window_forward
    map ctrl+shift+b        move_window_backward
    map ctrl+shift+`        move_window_to_top
    map ctrl+shift+1        first_window
    map ctrl+shift+2        second_window
    map ctrl+shift+3        third_window
    map ctrl+shift+4        fourth_window
    map ctrl+shift+5        fifth_window
    map ctrl+shift+6        sixth_window
    map ctrl+shift+7        seventh_window
    map ctrl+shift+8        eighth_window
    map ctrl+shift+9        ninth_window
    map ctrl+shift+0        tenth_window

    # Tab management
    map ctrl+shift+right    next_tab
    map ctrl+shift+left     previous_tab
    map ctrl+shift+t        new_tab
    map ctrl+shift+q        close_tab
    map ctrl+shift+l        next_layout
    map ctrl+shift+.        move_tab_forward
    map ctrl+shift+,        move_tab_backward

    # Miscellaneous
    map ctrl+shift+up      increase_font_size
    map ctrl+shift+down    decrease_font_size
    map ctrl+shift+backspace restore_font_size
```

</details>
</details>

<details>

<summary><strong>🇼  WezTerm</strong></summary>

<div style="margin-left: 20px;">

<details>

<summary>How do I enable WezTerm?</summary>

Edit the `/ddubsOS/modules/home/wezterm.nix` Change `enable = false` to
`enable = true;`\
Save the file and rebuild zaneyos with the `fr` command.

```
{pkgs, ...}: {
  programs.wezterm = {
    enable = false;
    package = pkgs.wezterm;
  };
```

</details>

<details>
 <summary>What are the WezTerm keybindings and how can I change them?</summary>

The kitty bindings are configured in `~/ddubsOS/modules/home/wezterm.nix`

The defaults are:

```text
ALT is the defined META key for WezTerm
  -- Tab management
ALT + t                 Open new Tab
ALT + w                 Close current Tab
ALT + n                 Move to next Tab
ALT + p                 Move to previous Tab 
  -- Pane management
ALT + v                 Create Vertical Split
ALT + h                 Create Horizontal Split
ALT + q                 Close Current Pane
   -- Pane navigation (move between panes with ALT + Arrows)
ALT + Left Arrow        Move to pane -- Left
ALT + Right Arrow       Move to pane -- Right
ALT + Down Arrow        Move to pane -- Down
ALT + Up Arrow          Move to pane -- Down
```

</details>
</div>
</details>

<details>
<summary><strong>👻 Ghostty </strong></summary>

<div style="margin-left: 20px;">

<details>
<summary> How do I enable the ghostty terminal? </summary>

1. Edit the `~/ddubsOS/modules/home/ghostty.nix` file.
2. Change `enable = true;`
3. Run the command alias `fr` to create a new generation.

</details>

<details>

<summary> How do I change the ghostty theme?   </summary>

1. Edit the `~/ddubsOS/modules/home/ghostty.nix` file.
2. There are several example themes included but commented out.

```text
#theme = Aura
theme = Dracula
#theme = Aardvark Blue
#theme = GruvboxDarkHard
```

3. Comment out `Dracula` and either uncomment one of the others or add one of
   ghostty's many themes.

</details>

<details>
<summary> What are the default ghostty keybindings?  </summary>

```text
 # keybindings
    keybind = alt+s>r=reload_config
    keybind = alt+s>x=close_surface

    keybind = alt+s>n=new_window

    # tabs
    keybind = alt+s>c=new_tab
    keybind = alt+s>shift+l=next_tab
    keybind = alt+s>shift+h=previous_tab
    keybind = alt+s>comma=move_tab:-1
    keybind = alt+s>period=move_tab:1

    # quick tab switch
    keybind = alt+s>1=goto_tab:1
    keybind = alt+s>2=goto_tab:2
    keybind = alt+s>3=goto_tab:3
    keybind = alt+s>4=goto_tab:4
    keybind = alt+s>5=goto_tab:5
    keybind = alt+s>6=goto_tab:6
    keybind = alt+s>7=goto_tab:7
    keybind = alt+s>8=goto_tab:8
    keybind = alt+s>9=goto_tab:9

    # split
    keybind = alt+s>\=new_split:right
    keybind = alt+s>-=new_split:down

    keybind = alt+s>j=goto_split:bottom
    keybind = alt+s>k=goto_split:top
    keybind = alt+s>h=goto_split:left
    keybind = alt+s>l=goto_split:right

    keybind = alt+s>z=toggle_split_zoom

    keybind = alt+s>e=equalize_splits
```

</details>
</div>
</details>

## 🪧 General NixOS related topics

<details>
<summary><strong>❄  What are Flakes in NixOS? </strong></summary>

<div style="margin-left: 20px;">

**Flakes** are a feature of the Nix package manager that simplifies and
standardizes how configurations, dependencies, and packages are managed. If
you're familiar with tools like `package.json` in JavaScript or `Cargo.toml` in
Rust, flakes serve a similar purpose in the Nix ecosystem.

#### Key Features of Flakes:

1. **Pin Dependencies**:
   - Flakes lock the versions of dependencies in a `flake.lock` file, ensuring
     reproducibility across systems.

2. **Standardize Configurations**:
   - They use a `flake.nix` file to define how to build, run, or deploy a
     project or system, making setups more predictable.

3. **Improve Usability**:
   - Flakes simplify sharing and reusing configurations across different systems
     or projects by providing a consistent structure.

In essence, flakes help manage NixOS setups or Nix-based projects in a more
portable and reliable way.

</div>

</details>

<details>
<summary><strong>🏡  What is NixOS Home Manager? </strong></summary>

**Home Manager** is a powerful tool in the Nix ecosystem that allows you to
declaratively manage user-specific configurations and environments. With Home
Manager, you can streamline the setup of dotfiles, shell settings, applications,
and system packages for your user profile.

### Key Features of Home Manager:

1. **Declarative Configuration**:
   - Define all your settings and preferences in a single `home.nix` file,
     making it easy to track, share, and replicate your setup.

2. **Cross-Distribution Support**:
   - Home Manager works not only on NixOS but also on other Linux distributions
     and macOS, allowing you to standardize configurations across devices.

3. **User Environment Management**:
   - Manage applications, environment variables, shell configurations, and
     more—all isolated to your user profile.

### Why Use Home Manager?

Home Manager simplifies system management by offering consistency,
reproducibility, and portability. Whether you’re customizing your development
environment or sharing configurations between machines, it provides an efficient
way to tailor your user experience.

</details>

<details>
<summary><strong>🏭  What are Atomic Builds?</strong></summary>

**Atomic builds** in NixOS ensure that any system change (like installing
software or updating the configuration) is applied in a safe and fail-proof way.
This means that a system update is either fully successful or has no effect at
all, eliminating the risk of a partially applied or broken system state.

### How Atomic Builds Work:

1. **Immutable System Generation**:
   - Every configuration change creates a new "generation" of the system, while
     the previous ones remain untouched. You can easily roll back to an earlier
     generation if something goes wrong.

2. **Transaction-Like Behavior**:
   - Similar to database transactions, changes are applied atomically: either
     they succeed and become the new active system, or they fail and leave the
     current system unchanged.

3. **Seamless Rollbacks**:
   - In case of errors or issues, you can reboot and select a previous system
     generation from the boot menu to return to a working state.

### Benefits of Atomic Builds:

- **Reliability**: Your system is always in a consistent state, even if a
  configuration change fails.
- **Reproducibility**: The same configuration will always produce the same
  system state, making it easy to debug or replicate.
- **Ease of Rollback**: Reverting to a working configuration is as simple as
  rebooting and selecting the previous generation.

### Why NixOS Uses Atomic Builds:

This feature is a cornerstone of NixOS's declarative and reproducible design
philosophy, ensuring that system management is predictable and stress-free.

</details>

<details>
<summary><strong>❓ I am new to NIXOS where can I go to get more info? </strong></summary>

- [NIXOS Config Guide](https://www.youtube.com/watch?v=AGVXJ-TIv3Y&t=34s)
- [VIMJOYER YouTube Channel](https://www.youtube.com/@vimjoyer/videos)
- [Librephoenix YouTube Channel](https://www.youtube.com/@librephoenix)
- [8 Part Video Series on NIXOS](https://www.youtube.com/watch?v=QKoQ1gKJY5A&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq-)
- [Great guide for NixOS and Flakes](https://nixos-and-flakes.thiscute.world/preface)

</details>

<details>
<summary><strong>🏤 Where can I get info on using GIT repositories  </strong></summary>

- [Managing NIXOS config with GIT](https://www.youtube.com/watch?v=20BN4gqHwaQ)
- [GIT for dummies](https://www.youtube.com/watch?v=K6Q31YkorUE)
- [How GIT works](https://www.youtube.com/watch?v=e9lnsKot_SQ)
- [In depth 1hr video on GIT](https://www.youtube.com/watch?v=S7XpTAnSDL4&t=123s)

</details>
