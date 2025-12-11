English | [Español](./FAQ.es.md)

# 💬 ddubsOS FAQ for v2.7.1

- **Date:** 5-December-2025

---

## 📖 Table of Contents

### [🔧 Core System](#-core-system)

- [Host vs Profile Building](#host-vs-profile-building)
- [Host Management with zcli](#host-management-with-zcli)
- [Migration to Host-based Targets](#migration-to-host-based-targets)
- [Installer Flags](#installer-flags)
- [ZCLI Command-line Utility](#zcli-command-line-utility)

### [🪟 Hyprland Environment](#-hyprland-environment)

- [Keybindings & Quick Help](#keybindings--quick-help)
- [Quick-Select Apps (qs-keybinds, qs-cheatsheets, qs-docs)](#quick-select-apps-qs-keybinds-qs-cheatsheets-qs-docs)
- [Application Launching](#application-launching)
- [Window Management](#window-management)
- [Workspaces & Navigation](#workspaces--navigation)
- [Layouts (Master vs Dwindle)](#layouts-master-vs-dwindle)

### [⚙️ Settings and Configuration](#-settings-and-configuration)

- [Starship Prompt](#starship-prompt)
- [Waybar & Panel Configuration](#waybar--panel-configuration)
- [Editor Options (VSCode/Helix)](#editor-options-vscodhelix)
- [Terminal Options](#terminal-options)
- [Desktop Environments](#desktop-environments)
- [Timezone & System Settings](#timezone--system-settings)
- [Monitor Configuration](#monitor-configuration)
- [Applications & Package Management](#applications--package-management)
- [Kernel Configuration](#kernel-configuration)
- [System Maintenance](#system-maintenance)

### [🤖 AI and LLM Infrastructure](#-ai-and-llm-infrastructure)

- [OpenWebUI + Ollama Setup](#openwebui--ollama-setup)
- [Model Recommendations](#model-recommendations)
- [Management & Troubleshooting](#management--troubleshooting)

### [🎨 Theming and Appearance](#-theming-and-appearance)

- [Stylix Configuration](#stylix-configuration)
- [Wallpaper Management](#wallpaper-management)

### [💻 Terminal Configuration](#-terminal-configuration)

- [Kitty Terminal](#kitty-terminal)
- [WezTerm Terminal](#wezterm-terminal)
- [Ghostty Terminal](#ghostty-terminal)
- [Yazi File Manager](#yazi-file-manager)

### [🔄 System Updates and Maintenance](#-system-updates-and-maintenance)

- [Updating ddubsOS](#updating-ddubsos)

### [📋 Project Information](#-project-information)

- [About ddubsOS](#about-ddubsos)
- [Project Structure](#project-structure)

### [❄️ NixOS Fundamentals](#-nixos-fundamentals)

- [Understanding Flakes](#understanding-flakes)
- [Home Manager](#home-manager)
- [Atomic Builds](#atomic-builds)
- [Learning Resources](#learning-resources)

---

## 🔧 Core System

### Host vs Profile Building

**By host** (new, preferred approach):

```bash
sudo nixos-rebuild switch --flake .#<host>
```

**By profile** (legacy, still available):

```bash
sudo nixos-rebuild switch --flake .#<profile>  # amd | intel | nvidia | nvidia-laptop | vm
```

📖 See also: `docs/upgrade-from-2.4.md`

### Host Management with zcli

| Command                             | Description                  |
| ----------------------------------- | ---------------------------- |
| `zcli add-host <name> [profile]`    | Add new host configuration   |
| `zcli del-host <name>`              | Delete host configuration    |
| `zcli rename-host <old> <new>`      | Rename existing host         |
| `zcli hostname set <name>`          | Set flake host only          |
| `zcli update-host [name] [profile]` | Update both host and profile |

### Migration to Host-based Targets

Example: migrating a VM from legacy profile targets to new host-based approach

1. **Switch to the refactor branch**:

   ```bash
   git switch ddubos-refactor
   ```

   ⚠️ **Important (v2.4 users)**: First rebuild with nixos-rebuild, not zcli

   ```bash
   sudo nixos-rebuild switch --flake .#vm  # Install updated zcli first
   ```

2. **Ensure host folder exists**:

   ```bash
   zcli add-host ddubsos-vm vm
   ```

   - Edit `hosts/ddubsos-vm/variables.nix` as needed

3. **Point flake to new host**:

   ```bash
   zcli update-host ddubsos-vm vm
   ```

4. **Rebuild with host target**:
   ```bash
   sudo nixos-rebuild switch --flake .#ddubsos-vm
   ```

> **Note**: Hyprpanel is the default panel. Initial login takes 30-60 seconds to
> load.\
> **SUPER + Enter** for terminal, **SUPER + D** for app menu.

### Installer Flags

```bash
./install-ddubsos.sh --host <name> --profile <gpu> --build-host --non-interactive
```

- `--host/--profile`: Preselect values
- `--build-host`: Build `.#<host>` target
- `--non-interactive`: Accept defaults without prompts

### ZCLI Command-line Utility

The `zcli` utility (v1.2.0) simplifies ddubsOS management.

#### 🚀 Core Commands

| Command        | Description                               |
| -------------- | ----------------------------------------- |
| `rebuild`      | Rebuild NixOS system configuration        |
| `rebuild-boot` | Rebuild and activate on next boot (safer) |
| `update`       | Update flake and rebuild system           |
| `cleanup`      | Clean old system generations              |
| `list-gens`    | List user and system generations          |
| `trim`         | Trim filesystems (SSD performance)        |
| `diag`         | Create diagnostic report (`~/diag.txt`)   |

#### 🏠 Host Management

- `update-host`: Auto-set host and profile with GPU detection
- **GPU Profiles**: `amd`, `intel`, `nvidia`, `nvidia-laptop`, `vm`

#### ⚙️ Advanced Options (v1.2.0)

| Flag            | Description                       |
| --------------- | --------------------------------- |
| `--dry, -n`     | Show what would be done (dry run) |
| `--ask, -a`     | Ask for confirmation              |
| `--cores N`     | Limit build to N CPU cores        |
| `--verbose, -v` | Verbose output                    |
| `--no-nom`      | Disable nix-output-monitor        |
| `--no-stage`    | Skip staging prompt               |
| `--stage-all`   | Auto-stage all files              |

#### 🆕 New in v1.1.0: Interactive Staging

- Rebuild commands list untracked/unstaged files
- Choose numbers or 'all' to stage, or press Enter to skip
- New command: `zcli stage [--all]`

#### 🔍 Settings Management (v1.0.4)

```bash
zcli settings set <attr> <value> [--dry-run]
zcli settings --list-browsers
zcli settings --list-terminals
```

#### 📊 Glances Server

| Command           | Description             |
| ----------------- | ----------------------- |
| `glances start`   | Start monitoring server |
| `glances stop`    | Stop monitoring server  |
| `glances restart` | Restart server          |
| `glances status`  | Show status and URLs    |
| `glances logs`    | Show server logs        |

#### Example Usage

```bash
zcli rebuild-boot --cores 4
zcli rebuild --verbose --ask
zcli update
```

---

## 🪟 Hyprland Environment

### Keybindings & Quick Help

**Interactive Keybinding Viewer**:

- **SUPER + SHIFT + K** → Opens `qs-keybinds` with real-time search
- Browse keybindings for Hyprland, Emacs, Kitty, WezTerm, Yazi
- Click any keybind to copy to clipboard
- Also accessible via waybar "keys" icon

### Quick-Select Apps (qs-keybinds, qs-cheatsheets, qs-docs)

ddubsOS includes three powerful Qt6 QML applications:

#### 🔑 qs-keybinds (SUPER + SHIFT + K)

- **Interactive keybindings viewer** with real-time search
- **Multi-mode support**: Hyprland, Emacs, Kitty, WezTerm, Yazi
- **Copy functionality**: Click to copy with notification
- **Category filtering**: Visual organization with themed badges

#### 📚 qs-cheatsheets (SUPER + SHIFT + C)

- **Comprehensive cheatsheets browser**
- **Multi-language support**: English and Spanish
- **Categories**: emacs, hyprland, kitty, wezterm, yazi, nixos
- **Real-time content viewing** with search

#### 📖 qs-docs (SUPER + SHIFT + D)

- **Technical documentation viewer**
- **Smart browsing**: Reads from `~/ddubsos/docs/`
- **Architecture guides**: System documentation
- **Multi-language**: English and Spanish

All apps feature modern Qt6 QML interface, floating windows, and keyboard
shortcuts.

### Application Launching

|| Keybinding | Action | || ------------------------ |
----------------------------------- | || `SUPER + Return` | Launch kitty
terminal | || `SUPER + Tab` | Toggle Quickshell Overview | ||
`SUPER + Shift + Return` | Launch rofi-launcher | | `SUPER + D` | Open Discord |
| `SUPER + W` | Launch Google Chrome | | `SUPER + Y` | Open yazi file manager |
| `SUPER + S` | Take screenshot | | `SUPER + V` | Show clipboard history | |
`SUPER + T` | Toggle pypr terminal | | `SUPER + M` | Open pavucontrol |

### Window Management

| Keybinding          | Action               |
| ------------------- | -------------------- |
| `SUPER + Q`         | Kill active window   |
| `SUPER + F`         | Toggle fullscreen    |
| `SUPER + Shift + F` | Toggle floating mode |
| `SUPER + P`         | Toggle pseudo tiling |
| `SUPER + SPACE`     | Float current window |

### Workspaces & Navigation

**Workspaces**:

- `SUPER + 1-10` → Switch to workspace 1-10
- `SUPER + Shift + 1-10` → Move window to workspace 1-10
- `SUPER + Control + ←/→` → Switch workspace forward/backward

**Focus Movement**:

- `SUPER + ←/→/↑/↓` or `SUPER + H/L/K/J` → Move focus

**Window Movement**:

- `SUPER + Shift + ←/→/↑/↓` or `SUPER + Shift + H/L/K/J` → Move window

**Window Cycling**:

- `Alt + Tab` → Cycle to next window

### Layouts (Master vs Dwindle)

**Master Layout**:

- Divides workspace into **master area** (primary window) and **stack area**
  (other windows)
- Ideal for focusing on single main window

**Dwindle Layout**:

- Binary tree-based tiling with dynamic splits
- Alternates between horizontal and vertical splits
- More dynamic space distribution

Check current layout: `hyprctl getoption general:layout`

---

## ⚙️ Settings and Configuration

### Starship Prompt

1. Edit `~/ddubsOS/hosts/HOSTNAME/variables.nix`
2. Find `starshipChoice` line
3. Choose from available options:

```nix
# Available Starship prompts
starshipChoice = ../../modules/home/cli/starship.nix;        # default
#starshipChoice = ../../modules/home/cli/starship-1.nix;
#starshipChoice = ../../modules/home/cli/starship-rbmcg.nix;
```

4. Run `zcli rebuild`

### Waybar & Panel Configuration

#### Switching Between HyprPanel and Waybar

1. Edit `~/ddubsOS/hosts/HOSTNAME/variables.nix`
2. Change `panelChoice`:

```nix
# Panel Choice
panelChoice = "hyprpanel";  # Modern panel with advanced features
# or
panelChoice = "waybar";     # Traditional bar with customizable modules
```

#### Waybar Theme Selection

```nix
# Available Waybar themes
waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;     # default
#waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
#waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
#waybarChoice = ../../modules/home/waybar/waybar-nerodyke.nix;
```

### Editor Options (VSCode/Helix)

Enable editors in `~/ddubsOS/hosts/HOSTNAME/variables.nix`:

```nix
# Editor Options
enableEvilhelix = true;   # Helix with Vim-style keybindings
enableVscode = false;     # Visual Studio Code
```

**Notes**:

- Both disabled by default for minimal system
- Doom Emacs and Neovim always available

### Terminal Options

Enable optional terminals:

```nix
# Terminal Options
enableAlacritty = true;   # GPU-accelerated Rust terminal
enableTmux = false;       # Terminal multiplexer
enablePtyxis = false;     # Modern GNOME terminal
```

**Core Terminals (Always Available)**:

- **Ghostty**: Modern terminal with excellent performance
- **Kitty**: GPU-based terminal with advanced graphics
- **Foot**: Lightweight Wayland terminal
- **WezTerm**: GPU-accelerated cross-platform terminal

### Desktop Environments

Enable optional DEs/WMs:

```nix
# Desktop Environment Options
gnomeEnable = false;      # Full GNOME desktop
bspwmEnable = true;       # BSPWM tiling WM
dwmEnable = false;        # DWM suckless WM
wayfireEnable = false;    # Wayfire Wayland compositor
```

**Notes**:

- All disabled by default (Hyprland is primary)
- Enable only one at a time to avoid conflicts

### Timezone & System Settings

Edit `~/ddubsOS/modules/core/system.nix`:

```nix
time.timeZone = "America/New_York";  # Change to your timezone
```

### Monitor Configuration

Edit `~/ddubsOS/hosts/<HOSTNAME>/variables.nix` and use the `hyprMonitorsV2`
structure:

**Single Monitor**:

```nix
hyprMonitorsV2 = [
  {
    output = "eDP-1";
    mode = "1920x1080@60";
    position = "0x0";
    scale = 1;
    enabled = true;
  }
];
```

**Dual Monitors**:

```nix
hyprMonitorsV2 = [
  {
    output = "DP-1";
    mode = "2560x1440@144";
    position = "0x0";
    scale = 1;
    enabled = true;
  }
  {
    output = "HDMI-A-1";
    mode = "1920x1080@60";
    position = "2560x0";  # to the right of DP-1
    scale = 1.25;
    enabled = true;
  }
];
```

**Discovery**: Run `hyprctl monitors` to list outputs and available modes.

### Applications & Package Management

#### Global Applications

Edit `~/ddubsOS/modules/core/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # existing packages...
  ### My Apps ###
  bottom
  lazygit
  mission-center
  # add your packages here
];
```

#### Host-Specific Applications

Edit `~/ddubsOS/hosts/<HOSTNAME>/host-packages.nix`:

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    audacity
    discord
    obs-studio
    # host-specific packages
  ];
}
```

#### Flatpak Management

1. Edit `modules/core/flatpak.nix` under `services.flatpak.packages`
2. Add/remove Flatpak app IDs from flathub.org
3. Run `zcli rebuild`
4. See detailed guide: `docs/HOWTO-Install-Remove-Flatpaks.md`

### Kernel Configuration

Override kernel in `~/ddubsOS/hosts/HOSTNAME/hardware.nix`:

```nix
boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;  # Example: kernel 6.12
boot.kernelModules = ["kvm-intel"];
```

**Available Kernel Types**:

- `linuxPackages` - Default stable LTS kernel (6.12.x in 25.05)
- `linuxPackages_latest` - Latest mainline kernel
- `linuxPackages_zen` - Performance-optimized for desktop/gaming
- `linuxPackages_hardened` - Security-focused with hardening patches
- `linuxPackages_rt` - Real-time kernel for low-latency applications

### System Maintenance

**Apply Configuration Changes**:

```bash
zcli rebuild  # Apply changes (run git add . if you created new files)
```

**Update Packages**:

```bash
zcli update  # Update flake inputs and rebuild
```

**Clean Old Generations**:

```bash
zcli cleanup  # Remove old system generations
```

**Enable Glances Monitoring**:

```nix
# In variables.nix
enableGlances = true;  # Access at http://localhost:61210
```

---

## 🤖 AI and LLM Infrastructure

### OpenWebUI + Ollama Setup

**Available on NVIDIA systems only** - Provides local language model inference
with web interface.

#### Quick Start

1. **Access Web Interface**: `http://localhost:3000`
2. **Download First Model**: Try `llama3.2:1b` for lightweight testing
3. **Command Line**: Use `ollama-webui-manager models`

#### Management Commands

```bash
# Service Control
ollama-webui-manager start/stop/restart
ollama-webui-manager status

# Monitoring
ollama-webui-manager logs [ollama|webui]

# Models
ollama-webui-manager models
ollama-webui-manager test
```

#### Access Points

- **Web Interface**: `http://localhost:3000` - Modern chat interface
- **API**: `http://localhost:11434` - Direct API access for development

### Model Recommendations

#### For 4GB GPUs (GTX 1650, RTX 3050, etc.)

| Model         | Size   | Use Case                    |
| ------------- | ------ | --------------------------- |
| `llama3.2:1b` | ~1GB   | Fast, lightweight chat      |
| `llama3.2:3b` | ~3GB   | Better quality, still fast  |
| `phi3:mini`   | ~2GB   | Microsoft's efficient model |
| `qwen2:1.5b`  | ~1GB   | Alibaba's lightweight model |
| `gemma:2b`    | ~1.4GB | Google's small but capable  |

#### For 6GB+ GPUs (GTX 1660, RTX 3060, RTX 4060, etc.)

| Model            | Size   | Use Case                        |
| ---------------- | ------ | ------------------------------- |
| `mistral:7b`     | ~4.1GB | General purpose, high quality   |
| `codellama:7b`   | ~3.8GB | Code generation and programming |
| `neural-chat:7b` | ~3.8GB | Intel's conversational model    |
| `vicuna:7b`      | ~3.8GB | Strong conversational abilities |

### Management & Troubleshooting

**Data Locations**:

- Models: `/var/lib/openwebui-ollama/ollama/`
- OpenWebUI Data: `/var/lib/openwebui-ollama/openwebui/`

**Performance Tips**:

- Start with smaller models (1B-3B parameters)
- Monitor VRAM with `nvidia-smi`
- Leave 1-2GB VRAM free for overhead
- Quantized models (-q4, -q8) use less VRAM

**Troubleshooting**:

```bash
ollama-webui-manager status  # Check service status
ollama-webui-manager logs    # View logs
ollama-webui-manager test    # Test connectivity
```

---

## 🎨 Theming and Appearance

### Stylix Configuration

#### Enable/Disable Stylix

**To Enable** (image-based theming):

1. Edit `~/ddubsOS/modules/core/stylix.nix`
2. Comment out the `base16Scheme` section
3. Select your image for color palette
4. Run `zcli rebuild`

**To Disable** (manual colors):

1. Uncomment the `base16Scheme` section in the same file
2. Run `zcli rebuild`

#### Change Stylix Image

Edit `~/ddubsOS/hosts/HOSTNAME/variables.nix`:

```nix
# Set Stylix Image
stylixImage = ../../wallpapers/YourWallpaper.jpg;
```

Wallpapers are stored in `~/ddubsOS/wallpapers/`

### Wallpaper Management

#### Adding Wallpapers

- Copy new wallpapers to `~/ddubsOS/wallpapers/` directory

#### Changing Background

- **SUPER + ALT + W** → Open wallpaper selector
- Use `waypaper` for additional options

#### Automatic Wallpaper Changes

1. Edit `~/ddubsOS/modules/home/hyprland/config.nix`
2. Comment out static wallpaper line
3. Add wallsetter:

```nix
exec-once = [
  # ... other startup items ...
  #"sleep 1.5 && swww img /path/to/static/wallpaper.jpg"
  "sleep 1 && wallsetter"  # Enable automatic wallpaper rotation
];
```

#### Change Rotation Interval

Edit `~/ddubsOS/modules/home/scripts/wallsetter` and modify the `TIMEOUT =`
value (in seconds).

---

## 💻 Terminal Configuration

### Kitty Terminal

#### Fix Cursor Issues

If cursor jumps around:

1. Edit `~/ddubsOS/modules/home/kitty.nix`
2. Change `cursor_trail 1` to `cursor_trail 0`
3. Run `zcli rebuild`

#### Key Bindings

**Clipboard**:

- `Ctrl+Shift+V` - Paste from selection
- `Shift+Insert` - Paste from selection

**Window Management**:

- `Alt+N` - New window in current directory
- `Alt+W` - Close window
- `Ctrl+Shift+Enter` - Horizontal split
- `Ctrl+Shift+S` - Vertical split

**Tabs**:

- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+Q` - Close tab
- `Ctrl+Shift+Right/Left` - Next/Previous tab

### WezTerm Terminal

#### Enable WezTerm

Edit `~/ddubsOS/modules/home/wezterm.nix`:

```nix
{pkgs, ...}: {
  programs.wezterm = {
    enable = true;  # Change from false
    package = pkgs.wezterm;
  };
}
```

#### Key Bindings (ALT is META key)

**Tab Management**:

- `ALT + T` - Open new tab
- `ALT + W` - Close current tab
- `ALT + N/P` - Next/Previous tab

**Pane Management**:

- `ALT + V` - Vertical split
- `ALT + H` - Horizontal split
- `ALT + Q` - Close pane
- `ALT + Arrow Keys` - Navigate panes

### Ghostty Terminal

#### Enable Ghostty

1. Edit `~/ddubsOS/modules/home/ghostty.nix`
2. Set `enable = true;`
3. Run `zcli rebuild`

#### Change Theme

Available themes in the same file:

```
#theme = Aura
theme = Dracula         # default
#theme = Aardvark Blue
#theme = GruvboxDarkHard
```

#### Key Bindings

**Window Management**:

- `ALT+S>N` - New window
- `ALT+S>X` - Close surface

**Tabs**:

- `ALT+S>C` - New tab
- `ALT+S>1-9` - Go to tab 1-9
- `ALT+S>Shift+H/L` - Previous/Next tab

**Splits**:

- `ALT+S>\` - Vertical split
- `ALT+S>-` - Horizontal split
- `ALT+S>H/J/K/L` - Navigate splits

### Yazi File Manager

#### Configuration

- Main config: `~/ddubsos/modules/home/yazi.nix`
- Uses VIM-style motions and keybindings
- Keymap: `~/ddubsos/modules/home/yazi/keymap.toml`

#### Fix Yazi Startup Error

If you see Lua runtime errors:

```bash
ya pack -u  # Update packages
```

Then restart yazi.

---

## 🔄 System Updates and Maintenance

### Updating ddubsOS

**For versions v1.0+**:

1. **Backup current config**:

   ```bash
   cp -rpv ~/ddubsOS ~/Backup-ddubsOS
   ```

2. **Pull updates**:

   ```bash
   cd ~/ddubsOS
   git stash && git pull
   ```

3. **Restore host configurations**:

   ```bash
   cp -rpv ~/Backup-ddubsOS/hosts/HOSTNAME ~/ddubsOS/hosts/
   ```

4. **Add files and rebuild**:

   ```bash
   git add .
   zcli rebuild
   ```

5. **Merge custom changes**: Manually merge any customizations you made to:
   - Hyprland keybindings
   - Waybar configurations
   - Additional packages in `modules/packages.nix`

**Important**: Don't copy the `default` host from backup - use the updated
template for new hosts.

---

## 📋 Project Information

### About ddubsOS

ddubsOS is a personal NixOS configuration that evolved from ZaneyOS:

- 🎯 **Purpose**: Provide a working, daily-driver NixOS setup
- 🔧 **Features**: Gaming (Steam), development, modern desktop environment
- 🤝 **Philosophy**: Share configurations "as-is" for others to fork and
  customize
- 🚫 **Not a distro**: No plans for install ISO - it's a configuration template

**Key Takeaway**: Fork ddubsOS and make it your own. Share improvements back to
the community.

### Project Structure

```
📂 ~/ddubsOS/
├── 📁 cheatsheets/          # Quick reference guides
├── 📁 docs/                 # Project documentation
├── 📁 features/             # zcli feature modules
├── 📁 hosts/                # Per-host configurations
│   ├── 📁 default/          # Template for new hosts
│   ├── 📁 asus/             # Example host configs
│   └── 📁 ...               # Other host configs
├── 📁 lib/                  # zcli shared libraries
├── 📁 modules/              # NixOS/Home Manager modules
│   ├── 📁 core/             # System-level modules
│   └── 📁 home/             # User-level modules
├── 📁 profiles/             # Hardware/GPU profiles
├── 📁 wallpapers/           # Wallpaper collection
├── 📄 flake.nix             # Main configuration
└── 📄 flake.lock            # Dependency lock file
```

---

## ❄️ NixOS Fundamentals

### Understanding Flakes

**Flakes** standardize and simplify NixOS configuration management (like
`package.json` for JavaScript):

**Key Features**:

1. **Reproducible**: Lock dependencies in `flake.lock`
2. **Portable**: Consistent structure across systems
3. **Predictable**: Standardized build/deploy processes

Flakes make NixOS configurations more shareable and reliable.

### Home Manager

**Home Manager** provides declarative user environment management:

**Features**:

- **Declarative**: Define user settings in `home.nix`
- **Cross-platform**: Works on NixOS, other Linux distros, macOS
- **Isolated**: User-specific configurations separate from system

Perfect for managing dotfiles, shell configs, and user applications.

### Atomic Builds

**Atomic builds** ensure safe system changes:

**How it works**:

1. **Immutable generations**: Each change creates new system generation
2. **Transaction-like**: Changes either fully succeed or have no effect
3. **Easy rollback**: Boot into previous generation if issues occur

**Benefits**:

- ✅ **Reliable**: System always in consistent state
- 🔄 **Reproducible**: Same config = same system state
- ⏪ **Safe**: Easy rollback to working configuration

### Learning Resources

**Video Tutorials**:

- [NixOS Config Guide](https://www.youtube.com/watch?v=AGVXJ-TIv3Y&t=34s)
- [VimJoyer YouTube Channel](https://www.youtube.com/@vimjoyer/videos) -
  Excellent NixOS content
- [LibrePhoenix Channel](https://www.youtube.com/@librephoenix) - Linux and
  NixOS tutorials
- [8-Part NixOS Series](https://www.youtube.com/watch?v=QKoQ1gKJY5A&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq-)

**Written Guides**:

- [NixOS and Flakes Book](https://nixos-and-flakes.thiscute.world/preface) -
  Comprehensive guide

**Git Resources**:

- [Managing NixOS with Git](https://www.youtube.com/watch?v=20BN4gqHwaQ)
- [Git for Beginners](https://www.youtube.com/watch?v=K6Q31YkorUE)
- [How Git Works](https://www.youtube.com/watch?v=e9lnsKot_SQ)
- [1-Hour Git Deep Dive](https://www.youtube.com/watch?v=S7XpTAnSDL4&t=123s)

---

_This FAQ is organized for easy navigation and quick reference. Use the table of
contents to jump to specific sections, and remember that most configuration
changes require running `zcli rebuild` to take effect._
