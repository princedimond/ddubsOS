English | [Español](./warp-terminal-current.es.md)

# Warp Terminal (Current) Module {#opt-programs.warp-terminal-current.enable}

This module provides access to the bleeding-edge/current version of Warp Terminal, packaged directly from the latest releases. 

Installs TWO separate executables:
- **`warp-terminal`** - Stable version from nixpkgs 
- **`warp-bld`** - Bleeding-edge version from vendored "current" package (this repo)

## Overview

- **Package**: `warp-terminal-current` 
- **Source**: Vendored in this repo at `pkgs/warp-terminal-current` (based on upstream Warp releases)
- **Updates**: Run `scripts/update-warp-current.sh` (or see below) to bump to the latest release with verified hashes
- **Platforms**: x86_64-linux, aarch64-linux
- **License**: Unfree (proprietary)

## Usage

Enable in your ddubsos configuration:

```nix
programs.warp-terminal-current = {
  enable = true;
  waylandSupport = true; # Default: true
};
```

### Customization Example

```nix
programs.warp-terminal-current = {
  enable = true;
  waylandSupport = true;
  desktopName = "Warp-Dev";  # Custom name in launcher
  iconName = "warp-terminal"; # Use standard icon instead of custom
};
```

## Options

### `programs.warp-terminal-current.enable`
- **Type**: Boolean
- **Default**: `false`
- **Description**: Whether to enable the current/bleeding-edge version of Warp Terminal

### `programs.warp-terminal-current.waylandSupport`
- **Type**: Boolean  
- **Default**: `true`
- **Description**: Enable Wayland support for Warp Terminal (sets `WARP_ENABLE_WAYLAND=1`)

### `programs.warp-terminal-current.package`
- **Type**: Package
- **Default**: `pkgs.warp-bld`
- **Description**: The warp-bld wrapper package to use (bleeding-edge; wraps `pkgs.warp-terminal-current`) (allows overrides)

### `programs.warp-terminal-current.desktopName`
- **Type**: String
- **Default**: `"Warp-bld"`
- **Description**: Name displayed in application launchers

### `programs.warp-terminal-current.iconName`
- **Type**: String
- **Default**: `"warp-terminal-bld"`
- **Description**: Icon name for the application

## Desktop Integration

When enabled, creates:
- **Two executables**: `warp-terminal` (stable) and `warp-bld` (bleeding-edge)
- **Desktop entry**: "Warp-bld" (distinguishable from stable version)  
- **Custom icon**: `warp-terminal-bld` with visual indicators for bleeding-edge version
- **GUI launcher**: Appears in application menus as "Warp-bld"
- **Keywords**: Searchable by "terminal", "bleeding", "edge", "current"

## Updates

Preferred workflow (recommended):
```bash
zcli update-warp          # bump vendored versions.json with verified SRI hashes
zcli rebuild              # rebuild to activate the new current version
```
- Optional: add --commit to auto-commit the versions bump: `zcli update-warp --commit`

Alternative (direct helpers):
```bash
scripts/update-warp-current.sh  # runs the vendored updater
zcli rebuild
```

Verify-only (no rebuild):
```bash
pkgs/warp-terminal-current/warp-latest.sh   # updates versions.json in-place
# Optionally commit the change
```

## Differences from Stable

- **Stable** (`warp-terminal`): Available in nixpkgs, updated with NixOS releases
- **Current** (`warp-terminal-current`): Latest upstream releases, updated frequently

## Troubleshooting

### Build Failures
If the package fails to build, it's likely due to:
1. Network issues downloading from releases.warp.dev
2. Hash mismatches (run `scripts/update-warp-current.sh` to refresh hashes)
3. Unfree license not allowed (should be handled automatically in ddubsos)

### Version Information
To check the current version:
```bash
nix eval .#packages.x86_64-linux.warp-terminal-current.version
```

## Integration Notes

This module follows ddubsos patterns:
- ✅ Uses overlay system for package exposure
- ✅ Integrates with zcli rebuild workflow  
- ✅ Respects ddubsos GPU profile system
- ✅ Works with integrated Home Manager
- ✅ Optional enable (doesn't affect existing users)
