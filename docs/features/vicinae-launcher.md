# Vicinae Launcher Integration

[Vicinae](https://github.com/vicinaehq/vicinae) is a high-performance, native launcher for Linux built with C++ and Qt. It provides Raycast-like functionality with extensible React/TypeScript extensions.

## Features

- **Fast Native Performance**: Built with C++ and Qt for minimal resource usage
- **Raycast Compatibility**: Supports many existing Raycast extensions with minimal modification
- **Advanced Search**: File indexing with full-text search across millions of files
- **Smart Tools**: Built-in calculator, emoji picker, clipboard history
- **Extensible**: Server-side React/TypeScript extensions (no Electron/browser overhead)
- **Wayland First**: Native Wayland support with layer-shell integration

## Quick Start

### 1. Enable in Host Variables

```nix
# hosts/your-host/variables.nix
{
  # ... other variables ...
  
  # Enable Vicinae launcher
  enableVicinae = true;
  
  # Choose profile: "minimal", "standard", "developer", "power-user"
  vicinaeProfile = "developer";
}
```

The module will be automatically loaded when `enableVicinae = true`.

### 2. Configure Window Manager Keybindings

#### Hyprland
```nix
wayland.windowManager.hyprland.settings.bind = [
  ", Alt+Space, exec, vicinae"
];
```

#### i3/Sway
```nix
xsession.windowManager.i3.config.keybindings = {
  "Mod1+space" = "exec vicinae";  # Alt+Space
};
```

### 3. Build and Apply
```bash
sudo nixos-rebuild switch --flake .#your-host
```

## Usage

### Basic Commands
- Press `Alt+Space` (or your configured keybinding)
- Type to search applications, files, or use built-in tools
- Use arrow keys or `Tab`/`Shift+Tab` to navigate
- Press `Enter` to execute or `Escape` to cancel

### Built-in Tools
- **Calculator**: Type math expressions (e.g., `2+2`, `sin(30)`)
- **File Search**: Type file names or content to search
- **Clipboard History**: Access recently copied items
- **Emoji Picker**: Type `:emoji_name:` or search by description

## Profiles

### Minimal
- Basic application launching only
- No file search or clipboard history
- Minimal resource usage

### Standard (Default)
- Application launching
- File search enabled
- Clipboard history (500 items)
- No extensions

### Developer
- All standard features
- Calculator enabled
- Shortcuts optimization
- Raycast extensions enabled
- Optimized for coding workflows

### Power User
- All features enabled
- Advanced search settings
- Large clipboard history (2000 items)
- Content indexing
- Performance optimizations
- Custom extensions support

## Advanced Configuration

### Profile Configuration

```nix
# In hosts/your-host/variables.nix
{
  enableVicinae = true;
  
  # Profile determines feature set and performance
  vicinaeProfile = "power-user";  # Options below
}
```

**Available Profiles:**
- `"minimal"`: Basic launcher only, no extras
- `"standard"`: File search + clipboard history (500 items)
- `"developer"`: Standard + calculator + extensions + optimizations
- `"power-user"`: All features + advanced settings + performance tuning
```

### Custom Themes

A default `ddubsos-theme` is automatically included with colors that complement the ddubsOS aesthetic:

- **Background**: Dark charcoal (#1a1a1a)
- **Foreground**: Light gray (#e0e0e0) 
- **Accent Colors**: Blue (#61afef), Green (#98c379), Red (#e06c75), etc.

You can create additional themes by adding JSON files to `~/.config/vicinae/themes/` after installation.

## Integration Complete! 🎉

The Vicinae launcher has been successfully integrated into your ddubsos project with:

✅ **Flake Input**: Added to `flake.nix` with proper cachix configuration  
✅ **Home Manager Module**: Created in `modules/home/vicinae.nix`  
✅ **Variables Integration**: Uses ddubsOS variables pattern for configuration  
✅ **Example Host**: Ready-to-use host example with variables.nix  
✅ **Default Keybinding**: Set to `Alt+Space` (avoiding your existing `Super+Space`)  

### Next Steps

1. **Enable in a host**: Set `enableVicinae = true` in your host's variables.nix
2. **Choose profile**: Set `vicinaeProfile` to your preferred option
3. **Configure keybinding**: Add `Alt+Space` to your window manager config
4. **Build and test**: Run `sudo nixos-rebuild switch --flake .#your-host`

### File Locations

- **Config**: `~/.config/vicinae/vicinae.json`
- **Themes**: `~/.config/vicinae/themes/`
- **Extensions**: `~/.config/vicinae/extensions/`
