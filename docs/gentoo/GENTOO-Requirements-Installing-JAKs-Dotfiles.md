# Gentoo Hyprland Setup Guide for JaKooLit's Configuration

**Authored by Don Williams (ddubs)**

This guide provides a comprehensive package comparison between Arch Linux (JaKooLit's scripts) and Gentoo Linux, with specific instructions for new Gentoo users wanting to install Hyprland with JaKooLit's dotfiles.

## 📚 Essential Reading Before Starting

### Official Documentation:
- **Gentoo Handbook**: https://wiki.gentoo.org/wiki/Handbook:Main_Page
- **Gentoo Hyprland Wiki**: https://wiki.gentoo.org/wiki/Hyprland
- **Hyprland Official Wiki**: https://wiki.hyprland.org/
- **JaKooLit's Hyprland Dotfiles**: https://github.com/JaKooLit/Hyprland-Dots

### Important Gentoo Concepts:
- **Portage**: Gentoo's package manager (equivalent to pacman on Arch)
- **USE Flags**: Control what features are compiled into packages
- **Overlays**: Third-party package repositories (guru overlay is needed for some packages)
- **emerge**: Command to install packages (equivalent to `pacman -S`)
- **eix**: Fast package search tool (recommended to install first)

## ⚠️ Important Precautions

### 1. **Important Considerations**
Support for current Jak's Hyprland dotfiles requires Hyprland and supporting applications to be from the Gentoo testing branch. Current stable branch only has Hyprland v0.49, which will result in many Hyprland errors if used.

```bash
# To enable testing branch packages, add to /etc/portage/package.accept_keywords
echo 'gui-wm/hyprland ~amd64' | sudo tee -a /etc/portage/package.accept_keywords/hyprland
# Repeat for other Hyprland-related packages as needed
```

### 2. **Enable the GURU Overlay**
Many Hyprland-related packages are in the guru overlay:
```bash
sudo emerge --ask app-eselect/eselect-repository
sudo eselect repository enable guru
sudo emerge --sync guru
```

### 3. **USE Flag Configuration**
Hyprland requires specific USE flags. The emerge commands will prompt you with `--autounmask-write` when needed. Always review changes before applying:
```bash
# After --autounmask-write, apply changes with:
sudo etc-update --automode -5  # Auto-merge all changes
# OR for manual review:
sudo dispatch-conf
```

### 4. **System Requirements**
- **Graphics**: Ensure your GPU supports Wayland (AMD/Intel recommended, NVIDIA requires extra setup)
- **Kernel**: Modern kernel with DRM support
- **systemd**: These instructions assume systemd (not OpenRC)

### 5. **Compilation Time**
Gentoo compiles packages from source. Large packages like webkit-gtk can take significant time.

### 6. **Install eix First**
Makes package searching much faster:
```bash
sudo emerge -v app-portage/eix
sudo eix-update
```

## Application Requirements Based on Jak's Arch-Install Script

### Base Packages (00-base.sh)
- base-devel
- archlinux-keyring
- findutils

### Core Hyprland Packages (01-hypr-pkgs.sh)
**Essential (hypr_package):**
- bc ✓ (installed: sys-devel/bc)
- cliphist ✓ (available: gui-apps/cliphist)
- curl ✓ (installed: net-misc/curl)
- grim ✓ (available: gui-apps/grim)
- gvfs ✓ (available: gnome-base/gvfs)
- gvfs-mtp ✓ (included in gnome-base/gvfs with mtp USE flag)
- hyprpolkitagent (any Hyprland polkit works, e.g., gnome-extra/polkit-gnome)
- imagemagick ✓ (available: media-gfx/imagemagick)
- inxi ✓ (available: sys-apps/inxi)
- jq ✓ (installed: app-misc/jq)
- kitty ✓ (installed: x11-terms/kitty)
- kvantum ✗
- libspng ✓ (installed: media-libs/libspng)
- nano ✓ (available: app-editors/nano)
- network-manager-applet ✓ (available: gnome-extra/nm-applet)
- pamixer ✓ (available: media-sound/pamixer)
- pavucontrol ✓ (available: media-sound/pavucontrol)
- playerctl ✓ (available: media-sound/playerctl)
- python-requests ✓ (installed: dev-python/requests)
- python-pyquery ✓ (available: dev-python/pyquery)
- qt5ct ✓ (available: x11-misc/qt5ct)
- qt6ct ✗ (not available in Gentoo)
- qt6-svg ✓ (installed: dev-qt/qtsvg)
- rofi ✓ (installed: x11-misc/rofi)
- slurp ✓ (available: gui-apps/slurp)
- swappy ✓ (available: gui-apps/swappy)
- swaync ✓ (available: gui-apps/swaync)
- swww ✓ (available: gui-apps/swww)
- unzip ✓ (installed: app-arch/unzip)
- wallust ✓ (available in guru overlay - x11-misc/wallust)
- waybar ✓ (installed: gui-apps/waybar)
- wget ✓ (installed: net-misc/wget)
- wl-clipboard ✓ (available: gui-apps/wl-clipboard)
- wlogout ✓ (available: gui-apps/wlogout)
- xdg-user-dirs ✓ (available: x11-misc/xdg-user-dirs)
- xdg-utils ✓ (installed: x11-misc/xdg-utils)
- yad ✓ (available in guru overlay - gnome-extra/yad) **REQUIRED for help dialogs**

**Optional (hypr_package_2):**
- brightnessctl ✓ (available: app-misc/brightnessctl)
- btop ✓ (installed: sys-process/btop)
- cava ✓ (available: media-sound/cava)
- loupe ✓ (available: media-gfx/loupe)
- fastfetch ✓ (installed: app-misc/fastfetch)
- gnome-system-monitor ✓ (available: gnome-extra/gnome-system-monitor)
- mousepad ✓ (available: app-editors/mousepad)
- mpv ✓ (available: media-video/mpv)
- mpv-mpris (built-in with mpv in Gentoo)
- nvtop ✓ (available: sys-process/nvtop)
- nwg-look ✓ (installed: app-misc/nwg-look)
- nwg-displays ✓ (available: gui-apps/nwg-displays)
- pacman-contrib ✗ (Arch-specific)
- qalculate-gtk ✓ (available: sci-calculators/qalculate-gtk)
- yt-dlp ✓ (available: net-misc/yt-dlp)

### Hyprland Core (hyprland.sh)
- hyprland ✓ (installed: gui-wm/hyprland)
- hypridle ✓ (installed: gui-apps/hypridle)
- hyprlock ✓ (installed: gui-apps/hyprlock)

### Pipewire (pipewire.sh)
- pipewire ✓ (installed: media-video/pipewire)
- wireplumber ✓ (installed: media-video/wireplumber)
- pipewire-audio ✓ (part of media-video/pipewire)
- pipewire-alsa ✓ (part of media-video/pipewire)
- pipewire-pulse ✓ (part of media-video/pipewire)
- sof-firmware ✓ (installed: sys-firmware/sof-firmware)

### Fonts (fonts.sh)
- adobe-source-code-pro-fonts ✗
- noto-fonts-emoji ✗
- otf-font-awesome ✗ (similar: media-fonts/fontawesome)
- ttf-droid ✗
- ttf-fira-code ✓ (installed: media-fonts/fira-code)
- ttf-fantasque-nerd ✗
- ttf-jetbrains-mono ✓ (installed: media-fonts/jetbrains-mono)
- ttf-jetbrains-mono-nerd ✗
- ttf-victor-mono ✗
- noto-fonts ✗

### GTK Themes (gtk_themes.sh)
- unzip ✓ (installed: app-arch/unzip)
- gtk-engine-murrine ✗

### Battery Monitor (battery-monitor.sh)
- acpi ✗
- libnotify ✗

## Summary Statistics

**Available for Installation:** 38/40 packages from priority list
**Success Rate:** ~95%
**Packages Requiring Alternatives:** 2 (cliphist→clipman, hyprpolkitagent→polkit-gnome)

## Critical Missing Packages for Full Functionality

### High Priority:
1. **Screenshot/Screen Capture:**
   - grim (Wayland screenshot tool)
   - slurp (Wayland screen area selector)
   - swappy (screenshot editor)
   - hyprshot (Hyprland screenshot utility)

2. **Clipboard Management:**
   - cliphist (clipboard history)
   - wl-clipboard (Wayland clipboard utilities)

3. **Notifications:**
   - swaync (notification daemon)
   - libnotify (for battery monitor)

4. **Wallpaper:**
   - swww (animated wallpaper)
   - wallust (color palette generator)

5. **Audio:**
   - pamixer (PulseAudio/PipeWire mixer)
   - pavucontrol (PulseAudio volume control)
   - playerctl (media player control)

6. **Brightness:**
   - brightnessctl (laptop brightness control)

7. **Polkit:**
   - hyprpolkitagent (authentication agent for Hyprland)

8. **File Management:**
   - gvfs (virtual file system)
   - gvfs-mtp (MTP device support)

9. **System Tools:**
   - imagemagick (image manipulation)
   - inxi (system information)
   - nano (text editor - or use vim/neovim)

10. **Session Management:**
    - wlogout (logout menu)
    - xdg-user-dirs (user directory management)

11. **Qt Theming:**
    - qt5ct (Qt5 configuration)
    - qt6ct (Qt6 configuration)
    - kvantum (Qt theme engine)

12. **Network:**
    - network-manager-applet (NM system tray)

13. **Python:**
    - python-pyquery (Python library)

14. **Misc:**
    - yad (dialog tool)

### Medium Priority:
- nwg-displays (display configuration)
- mousepad (text editor)
- mpv + mpv-mpris (media player)
- nvtop (GPU monitoring)
- loupe (image viewer)
- cava (audio visualizer)
- qalculate-gtk (calculator)
- yt-dlp (YouTube downloader)

### Low Priority (Optional):
- gnome-system-monitor (system monitor)

### Battery Monitoring:
- acpi

### GTK Theme Engine:
- gtk-engine-murrine

### Fonts:
- adobe-source-code-pro-fonts
- noto-fonts-emoji
- ttf-droid
- ttf-fantasque-nerd
- ttf-jetbrains-mono-nerd
- ttf-victor-mono
- noto-fonts

## 🚀 How I Installed Gentoo

### These Are the Steps I Used

#### 1. Install Core System Tools First
```bash
# Install eix for fast package searching
sudo emerge -v app-portage/eix
sudo eix-update
```

#### 2. Install Hyprland Core
```bash
# Main compositor and ecosystem
sudo emerge -v gui-wm/hyprland gui-apps/hypridle gui-apps/hyprlock
```

#### 3. Install Core Wayland Tools
```bash

# Screenshots and wallpaper
sudo emerge -v gui-apps/grim gui-apps/slurp gui-apps/swappy gui-apps/swww gui-apps/hyprshot

#### 4. Install Clipboard Management
```bash
# Note: cliphist not available, use clipman instead
sudo emerge -v gui-apps/clipman gui-apps/wl-clipboard
```

#### 5. Install Notifications
```bash
sudo emerge -v gui-apps/swaync
# libnotify will be pulled in as dependency
```

#### 6. Install Audio Controls
```bash
sudo emerge -v media-sound/pamixer media-sound/pavucontrol media-sound/playerctl
```

#### 7. Install System Utilities
```bash
sudo emerge -v app-misc/brightnessctl media-gfx/imagemagick sys-apps/inxi gnome-base/gvfs app-editors/nano
```

#### 8. Install Qt Theming
```bash
# Note: qt6ct not available in Gentoo
sudo emerge -v x11-themes/kvantum x11-misc/qt5ct
```

**IMPORTANT - For QuickShell users:**
```bash
# Enable qml USE flag for Qt5Compat (required for GraphicalEffects)
echo 'dev-qt/qt5compat qml' | sudo tee -a /etc/portage/package.use/qt
sudo emerge -v dev-qt/qt5compat
```

#### 9. Install Network Manager Applet
```bash
sudo emerge -v gnome-extra/nm-applet
```

#### 10. Install Session Management
```bash
sudo emerge -v gui-apps/wlogout x11-misc/xdg-user-dirs
```

#### 11. Install Fonts
```bash
# Note: nerdfonts likely already installed
sudo emerge -v media-fonts/source-code-pro media-fonts/noto-emoji
```

#### 12. Install GTK Theme Engine
```bash
sudo emerge -v x11-themes/gtk-engines-murrine
```

#### 13. Install Battery Monitoring
```bash
sudo emerge -v sys-power/acpi
```

#### 14. Install Critical Tools for JaKooLit's Config
```bash
# YAD - REQUIRED for help dialogs and SDDM background prompts
# WALLUST - REQUIRED for wallpaper-based theming
# POLKIT-GNOME - REQUIRED for authentication dialogs
sudo emerge -v gnome-extra/yad x11-misc/wallust gnome-extra/polkit-gnome
```

#### 15. Install Python Libraries
```bash
sudo emerge -v dev-python/pyquery
```

#### 16. Install Optional Tools
```bash
sudo emerge -v app-editors/mousepad media-video/mpv sys-process/nvtop \
                media-gfx/loupe media-sound/cava gui-apps/nwg-displays \
                sci-calculators/qalculate-gtk net-misc/yt-dlp
```

#### 17. Install AGS v1.9.0 (Aylur's GTK Shell)

**Note:** AGS is not in Gentoo repos, so we build from source. AGS v1.9.0 is required for JaKooLit's desktop overview functionality.

**✅ Tested and Verified on Gentoo x86_64**

##### Important Gentoo-Specific Requirements:

1. **nodejs needs npm USE flag enabled**
2. **Correct package name**: `dev-libs/gjs` (NOT `gnome-base/gjs`)
3. **Gentoo uses `/usr/local/lib64/`** for typelibs (not `/usr/local/lib/`)
4. **Wrapper script required** to set `GI_TYPELIB_PATH`

##### Option 1: Using the Automated Script (Recommended)

A complete installation script is provided below. This handles all Gentoo-specific requirements automatically.

**Download and run:**
```bash
# Download the script
wget https://raw.githubusercontent.com/yourusername/scripts/main/agsv1-gentoo-install.sh
# Or create it manually (see script below)

# Make executable and run
chmod +x agsv1-gentoo-install.sh
./agsv1-gentoo-install.sh
```

**Complete Installation Script:**

<details>
<summary>Click to expand: agsv1-gentoo-install.sh</summary>

```bash
#!/bin/bash
# 💫 AGS v1.9.0 Installation Script for Gentoo 💫
# Adapted from JaKooLit's ags.sh for Gentoo Linux

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Symbols
ERROR="${RED}✗${RESET}"
OK="${GREEN}✓${RESET}"
INFO="${BLUE}ℹ${RESET}"
NOTE="${CYAN}★${RESET}"
WARN="${YELLOW}⚠${RESET}"

# AGS specific tag
ags_tag="v1.9.0"

# Gentoo package names for AGS dependencies
ags_gentoo=(
    dev-lang/typescript
    net-libs/nodejs
    dev-build/meson
    dev-libs/glib
    dev-libs/gjs
    x11-libs/gtk+:3
    gui-libs/gtk-layer-shell
    sys-power/upower
    net-misc/networkmanager
    dev-libs/gobject-introspection
    dev-libs/libdbusmenu
    net-libs/libsoup:3.0
)

echo -e "${NOTE} ${MAGENTA}AGS v1.9.0 Installation Script for Gentoo${RESET}\n"

# Check for nodejs npm USE flag
if ! equery list net-libs/nodejs 2>/dev/null | grep -q npm; then
    echo -e "${WARN} nodejs needs 'npm' USE flag enabled."
    echo -e "${INFO} Enabling npm USE flag for nodejs..."
    echo 'net-libs/nodejs npm' | sudo tee -a /etc/portage/package.use/nodejs >/dev/null
    echo -e "${OK} USE flag configured. Will reinstall nodejs if needed."
fi

# Check if AGS is already installed
if command -v ags &>/dev/null; then
    AGS_VERSION=$(ags -v 2>/dev/null | awk '{print $NF}')
    if [[ "$AGS_VERSION" == "1.9.0" ]]; then
        echo -e "${INFO} ${MAGENTA}Aylur's GTK Shell v1.9.0${RESET} is already installed. Skipping installation."
        exit 0
    else
        echo -e "${WARN} AGS version $AGS_VERSION found. Will upgrade to 1.9.0."
    fi
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${ERROR} This script should not be run as root. Please run as a normal user." 
   exit 1
fi

# Check for sudo access
if ! sudo -v; then
    echo -e "${ERROR} This script requires sudo privileges."
    exit 1
fi

echo -e "${NOTE} Installing ${CYAN}AGS dependencies${RESET}...\n"

# Install dependencies
failed_packages=()
for PKG in "${ags_gentoo[@]}"; do
    echo -e "${INFO} Checking ${YELLOW}$PKG${RESET}..."
    
    # Check if package is already installed (simple check)
    PKG_NAME=$(echo "$PKG" | cut -d: -f1)
    if equery list "$PKG_NAME" &>/dev/null; then
        echo -e "${OK} ${YELLOW}$PKG${RESET} is already installed."
    else
        echo -e "${INFO} Installing ${YELLOW}$PKG${RESET}..."
        if sudo emerge -v "$PKG"; then
            echo -e "${OK} ${YELLOW}$PKG${RESET} installed successfully."
        else
            echo -e "${ERROR} Failed to install ${YELLOW}$PKG${RESET}"
            failed_packages+=("$PKG")
        fi
    fi
    echo ""
done

# Check if any packages failed
if [ ${#failed_packages[@]} -gt 0 ]; then
    echo -e "${ERROR} The following packages failed to install:"
    for pkg in "${failed_packages[@]}"; do
        echo -e "  - ${RED}$pkg${RESET}"
    done
    echo -e "\n${WARN} Continuing anyway, but AGS may fail to build..."
    read -p "Press Enter to continue or Ctrl+C to abort..."
fi

echo -e "\n${NOTE} Installing and compiling ${CYAN}Aylur's GTK Shell $ags_tag${RESET}...\n"

# Check if directory exists and remove it
if [ -d "ags_v1.9.0" ]; then
    echo -e "${NOTE} Removing existing ags directory..."
    rm -rf "ags_v1.9.0"
fi

# Clone repository
echo -e "${INFO} Cloning ${CYAN}AGS $ags_tag${RESET} repository..."
if ! git clone --depth=1 https://github.com/JaKooLit/ags_v1.9.0.git; then
    echo -e "${ERROR} Failed to clone AGS repository. Check your internet connection."
    exit 1
fi

cd ags_v1.9.0 || exit 1

# Install npm dependencies
echo -e "\n${INFO} Installing npm dependencies..."
if ! npm install; then
    echo -e "${ERROR} npm install failed."
    cd ..
    exit 1
fi

# Setup meson build
echo -e "\n${INFO} Setting up meson build..."
if ! meson setup build; then
    echo -e "${ERROR} Meson setup failed."
    cd ..
    exit 1
fi

# Install AGS
echo -e "\n${INFO} Installing AGS (requires sudo)..."
if ! sudo meson install -C build; then
    echo -e "${ERROR} AGS installation failed."
    cd ..
    exit 1
fi

echo -e "\n${OK} ${YELLOW}Aylur's GTK Shell $ags_tag${RESET} installed successfully.\n"

# Create wrapper script for Gentoo lib64
echo -e "${NOTE} Creating wrapper script for Gentoo lib64 support..."
if [ -f "/usr/local/bin/ags" ]; then
    sudo mv /usr/local/bin/ags /usr/local/bin/ags.bin
    echo -e '#!/bin/bash\nexport GI_TYPELIB_PATH=/usr/local/lib64:$GI_TYPELIB_PATH\nexec /usr/local/bin/ags.bin "$@"' | sudo tee /usr/local/bin/ags > /dev/null
    sudo chmod +x /usr/local/bin/ags
    echo -e "${OK} Wrapper script created."
fi

# Apply launcher patch for GI typelibs search path
echo -e "${NOTE} Applying AGS launcher patch for GI typelibs search path..."
LAUNCHER="/usr/local/share/com.github.Aylur.ags/com.github.Aylur.ags"

if sudo test -f "$LAUNCHER"; then
    # 1) Switch from GIRepository ESM import to GLib and drop deprecated prepend_* calls
    sudo sed -i \
        -e 's|^import GIR from "gi://GIRepository?version=2.0";$|import GLib from "gi://GLib";|' \
        -e '/GIR.Repository.prepend_search_path/d' \
        -e '/GIR.Repository.prepend_library_path/d' \
        "$LAUNCHER"
    
    # 2) Inject GI_TYPELIB_PATH export right after the GLib import (use lib64 for Gentoo)
    sudo awk '{print} $0 ~ /^import GLib from "gi:\/\/GLib";$/ {print "const __old = GLib.getenv(\"GI_TYPELIB_PATH\");"; print "GLib.setenv(\"GI_TYPELIB_PATH\", \"/usr/local/lib64\" + (__old ? \":\" + __old : \"\"), true);"}' "$LAUNCHER" > /tmp/ags_launcher
    sudo mv /tmp/ags_launcher "$LAUNCHER"
    sudo chmod +x "$LAUNCHER"
    
    echo -e "${OK} AGS launcher patched successfully."
else
    echo -e "${WARN} Launcher not found at $LAUNCHER, skipping patch."
fi

# Cleanup
cd ..
echo -e "\n${INFO} Cleaning up..."
rm -rf ags_v1.9.0

# Verify installation
echo -e "\n${NOTE} Verifying installation..."
if command -v ags &>/dev/null; then
    AGS_VERSION=$(ags -v 2>/dev/null | awk '{print $NF}')
    if [[ -n "$AGS_VERSION" ]]; then
        echo -e "${OK} AGS version ${GREEN}$AGS_VERSION${RESET} installed successfully!"
    else
        echo -e "${OK} AGS installed successfully!"
    fi
    
    echo -e "\n${INFO} You can now run AGS with: ${YELLOW}ags${RESET}"
    echo -e "${INFO} For help, run: ${YELLOW}ags --help${RESET}"
else
    echo -e "${ERROR} AGS installation verification failed. Command not found."
    exit 1
fi

echo -e "\n${OK} ${GREEN}Installation complete!${RESET}\n"
```

</details>

##### Option 2: Manual Installation

If you prefer to install manually:

```bash
# 1. Enable nodejs npm USE flag
echo 'net-libs/nodejs npm' | sudo tee -a /etc/portage/package.use/nodejs

# 2. Install dependencies (note: dev-libs/gjs NOT gnome-base/gjs)
sudo emerge -v dev-lang/typescript net-libs/nodejs dev-build/meson \
               dev-libs/glib dev-libs/gjs x11-libs/gtk+:3 \
               gui-libs/gtk-layer-shell sys-power/upower \
               net-misc/networkmanager dev-libs/gobject-introspection \
               dev-libs/libdbusmenu net-libs/libsoup:3.0

# 3. Clone and build AGS
git clone --depth=1 https://github.com/JaKooLit/ags_v1.9.0.git
cd ags_v1.9.0
npm install
meson setup build
sudo meson install -C build

# 4. Create wrapper for lib64 support (REQUIRED for Gentoo)
sudo mv /usr/local/bin/ags /usr/local/bin/ags.bin
cat << 'EOF' | sudo tee /usr/local/bin/ags
#!/bin/bash
export GI_TYPELIB_PATH=/usr/local/lib64:$GI_TYPELIB_PATH
exec /usr/local/bin/ags.bin "$@"
EOF
sudo chmod +x /usr/local/bin/ags

# 5. Apply launcher patch
LAUNCHER="/usr/local/share/com.github.Aylur.ags/com.github.Aylur.ags"
sudo sed -i \
    -e 's|^import GIR from "gi://GIRepository?version=2.0";$|import GLib from "gi://GLib";|' \
    -e '/GIR.Repository.prepend_search_path/d' \
    -e '/GIR.Repository.prepend_library_path/d' \
    "$LAUNCHER"

sudo awk '{print} $0 ~ /^import GLib from "gi:\/\/GLib";$/ {print "const __old = GLib.getenv(\"GI_TYPELIB_PATH\");"; print "GLib.setenv(\"GI_TYPELIB_PATH\", \"/usr/local/lib64\" + (__old ? \":\" + __old : \"\"), true);"}' "$LAUNCHER" > /tmp/ags_launcher
sudo mv /tmp/ags_launcher "$LAUNCHER"
sudo chmod +x "$LAUNCHER"

# 6. Verify
ags --version  # Should output: 1.9.0

# 7. Cleanup
cd ..
rm -rf ags_v1.9.0
```

##### Verification:

```bash
ags --version
# Expected output: 1.9.0
```

##### Common Issues:

**Issue 1: "npm: command not found"**
- Solution: Enable npm USE flag for nodejs (script handles this automatically)

**Issue 2: "Typelib file for namespace 'GUtils' not found"**
- Solution: Wrapper script sets GI_TYPELIB_PATH to /usr/local/lib64 (script handles this automatically)

**Issue 3: "gnome-base/gjs not found"**
- Solution: Use `dev-libs/gjs` instead (script uses correct package name)

## 💡 Important Tips for Gentoo Users

### Package Installation Tips:

1. **USE Flag Conflicts**: When emerge reports USE flag conflicts, use:
   ```bash
   sudo emerge -v --autounmask-write <package>
   sudo etc-update --automode -5
   sudo emerge -v <package>
   ```

2. **Check Package Availability**:
   ```bash
   eix <package-name>  # Fast search
   emerge -s <package-name>  # Standard search
   ```

3. **Installation Progress**: Large packages (webkit-gtk, mpv) can take 30+ minutes to compile.

4. **Dependency Resolution**: Portage will automatically handle dependencies, but review the list before proceeding.

### Hyprland-Specific Configuration:

1. **Start Polkit Agent**: Add to `~/.config/hypr/hyprland.conf`:
   ```bash
   exec-once = /usr/libexec/polkit-gnome-authentication-agent-1
   ```

2. **Start Clipboard Manager**: Add to hyprland.conf:
   ```bash
   exec-once = wl-paste --type text --watch clipman store
   exec-once = wl-paste --type image --watch clipman store
   ```

3. **Graphics Drivers**: Ensure proper driver installation:
   - **AMD**: `media-libs/mesa` with `VIDEO_CARDS="amdgpu radeonsi"`
   - **Intel**: `media-libs/mesa` with `VIDEO_CARDS="intel iris"`
   - **NVIDIA**: Follow Gentoo's NVIDIA guide (more complex for Wayland)

### Package Equivalents and Alternatives:

| Arch Package | Gentoo Equivalent | Notes |
|-------------|------------------|-------|
| `cliphist` | `gui-apps/clipman` | Functionally equivalent |
| `hyprpolkitagent` | `gnome-extra/polkit-gnome` | Compatible alternative |
| `qt6ct` | Not available | Use Qt6 native theming |
| `yad` | `gnome-extra/yad` | In guru overlay |
| `wallust` | `x11-misc/wallust` | In guru overlay |

### Troubleshooting:

1. **Package Not Found**: Check if guru overlay is enabled:
   ```bash
   eselect repository list
   ```

2. **Compilation Errors**: Check for missing dependencies or USE flags:
   ```bash
   emerge --info <package>
   ```

3. **Performance**: Consider using:
   ```bash
   # In /etc/portage/make.conf
   MAKEOPTS="-j$(nproc)"
   EMERGE_DEFAULT_OPTS="--jobs 4 --load-average $(nproc)"
   ```

### Post-Installation Configuration:

1. **Create Hyprland Desktop Entry** (for display managers):
   ```bash
   sudo mkdir -p /usr/local/share/wayland-sessions
   sudo tee /usr/local/share/wayland-sessions/hyprland.desktop << 'EOF'
   [Desktop Entry]
   Name=Hyprland
   Comment=An intelligent dynamic tiling Wayland compositor
   Exec=Hyprland
   Type=Application
   EOF
   ```

2. **Enable Services** (if using systemd):
   ```bash
   systemctl --user enable pipewire pipewire-pulse wireplumber
   ```

3. **Deploy JaKooLit Dotfiles**:
   ```bash
   git clone https://github.com/JaKooLit/Hyprland-Dots.git
   cd Hyprland-Dots
   # Follow JaKooLit's installation instructions
   ```

4. **Test Critical Components**:
   ```bash
   # Screenshot
   grim ~/test.png
   
   # Wallpaper theming
   wallust ~/Pictures/wallpaper.png
   
   # Dialog
   yad --info --text="Test dialog"
   ```

## 📖 Additional Resources

- **Gentoo Wiki - Wayland**: https://wiki.gentoo.org/wiki/Wayland
- **Gentoo Forums**: https://forums.gentoo.org/
- **Hyprland Discord**: https://discord.gg/hyprland
- **JaKooLit's Documentation**: https://github.com/JaKooLit/Hyprland-Dots/wiki

## ⚠️ Known Issues

1. **NVIDIA Users**: Wayland support on NVIDIA requires:
   - Driver version 495+
   - `nvidia-drm.modeset=1` kernel parameter
   - Environment variables in hyprland.conf

2. **VM Users**: Disable Bluetooth packages:
   ```bash
   # Skip bluez, bluez-utils, blueman installations
   ```

3. **Qt6 Applications**: Without qt6ct, theme using environment variables:
   ```bash
   export QT_QPA_PLATFORMTHEME=qt5ct  # Falls back to Qt5 theming
   ```

## 🎯 Quick Installation Script

For experienced users, here's a one-liner approach (review before running):

```bash
# Install all essential packages
sudo emerge -v \
  app-portage/eix \
  gui-wm/hyprland gui-apps/hypridle gui-apps/hyprlock \
  gui-apps/grim gui-apps/slurp gui-apps/swappy gui-apps/swww gui-apps/hyprshot \
  gui-apps/clipman gui-apps/swaync \
  media-sound/pamixer media-sound/pavucontrol media-sound/playerctl \
  app-misc/brightnessctl media-gfx/imagemagick sys-apps/inxi \
  gnome-base/gvfs x11-themes/kvantum x11-misc/qt5ct \
  gnome-extra/nm-applet gui-apps/wlogout x11-misc/xdg-user-dirs \
  media-fonts/source-code-pro media-fonts/noto-emoji \
  x11-themes/gtk-engines-murrine sys-power/acpi \
  gnome-extra/yad x11-misc/wallust gnome-extra/polkit-gnome \
  dev-python/pyquery
```

**Note**: USE flag conflicts will require --autounmask-write as shown above.

## 🎉 Verification

After installation, verify critical components:

```bash
# Check all binaries are available
which hyprland grim slurp swappy hyprshot clipman swaync \
      pamixer playerctl brightnessctl wallust yad

# Check polkit agent
ls /usr/libexec/polkit-gnome-authentication-agent-1

# Test eix
eix hyprland
```

If all commands succeed, you're ready to install JaKooLit's dotfiles!
