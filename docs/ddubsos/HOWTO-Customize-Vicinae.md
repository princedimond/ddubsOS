# Vicinae Customization Guide

## Removing Unwanted Default Items

Vicinae comes with several built-in items that may not be relevant for your setup. Here's how to remove or disable them.

### Method 1: NixOS Configuration (Automated)

The ddubsOS vicinae module already includes configuration to disable many unwanted items:

```nix
# Already configured in modules/home/vicinae.nix
builtins = {
  # Disabled items
  store.enabled = false;              # Extension store
  documentation.enabled = false;      # Documentation links  
  sponsor.enabled = false;            # Sponsor/funding links
  themeManager.enabled = false;       # Theme browser
  extensionStore.enabled = false;     # Extension marketplace
  
  # Enabled useful items
  applications.enabled = true;        # App launcher
  system.enabled = true;             # System controls
};
```

### Method 2: Manual Configuration (Fine-tuning)

After Vicinae starts for the first time, you can manually edit the configuration:

#### Configuration File Location
```bash
~/.config/vicinae/vicinae.json
```

#### Example Configuration Edits

```json
{
  "builtins": {
    "store": {
      "enabled": false,
      "showInRootSearch": false
    },
    "documentation": {
      "enabled": false,
      "showInRootSearch": false
    },
    "sponsor": {
      "enabled": false,
      "showInRootSearch": false
    },
    "themeManager": {
      "enabled": false,
      "showInRootSearch": false
    },
    "raycastStore": {
      "enabled": false,
      "showInRootSearch": false
    }
  },
  "rootSearch": {
    "hiddenBuiltins": [
      "store",
      "documentation", 
      "sponsor",
      "themeManager",
      "extensionStore",
      "raycast-store",
      "manage-extensions",
      "get-help",
      "report-bug",
      "upgrade-vicinae",
      "about-vicinae"
    ]
  }
}
```

### Method 3: UI Configuration (Interactive)

1. Launch Vicinae (`Alt+Space`)
2. Type "preferences" or "settings"
3. Navigate to Built-ins or Extensions section
4. Toggle off unwanted items:
   - ❌ **Store** - Extension marketplace
   - ❌ **Documentation** - Help links
   - ❌ **Sponsor** - Funding/donate links
   - ❌ **Theme Manager** - Theme browser (if not needed)
   - ❌ **Get Help** - Support links
   - ❌ **Report Bug** - Bug reporting
   - ❌ **Upgrade** - Update notifications

### Items to Keep Enabled ✅

**Core functionality:**
- ✅ **Applications** - Launch installed apps
- ✅ **System** - System controls (logout, shutdown, etc.)
- ✅ **Calculator** - Math expressions
- ✅ **Clipboard History** - Recent clipboard items
- ✅ **File Search** - Search for files
- ✅ **Shortcuts** - Quick bookmarks/links

**Developer tools (if using developer profile):**
- ✅ **Terminal** - Quick terminal access
- ✅ **Process Manager** - Kill processes
- ✅ **Network** - IP info, network status

### Clean Minimal Setup

For the cleanest experience, disable everything except:
```json
{
  "builtins": {
    "applications": { "enabled": true },
    "calculator": { "enabled": true },
    "clipboardHistory": { "enabled": true },
    "fileSearch": { "enabled": true },
    "system": { "enabled": true }
  }
}
```

### Troubleshooting

**Config not applying?**
1. Restart Vicinae: `pkill vicinae && vicinae server &`
2. Check config syntax: `cat ~/.config/vicinae/vicinae.json | jq .`
3. Reset to defaults: `rm ~/.config/vicinae/vicinae.json`

**Items still showing?**
1. Clear cache: `rm -rf ~/.local/share/vicinae/cache`
2. Check for user overrides in the UI settings
3. Some items might be hardcoded and require UI disabling

**Performance after customization:**
- Fewer enabled builtins = faster search
- Disable unused extensions for better performance
- Use `minimal` or `standard` profile for basic setups

### Profile-Specific Recommendations

**Minimal Profile:**
- Only Applications + Calculator
- No extensions, no advanced features

**Standard Profile:** 
- Applications, Calculator, Clipboard, File Search
- No store, documentation, or extensions

**Developer Profile:**
- All useful tools enabled
- Store/sponsor items disabled
- Extensions enabled for development tools

**Power User Profile:**
- All features except marketing items
- Advanced search and indexing
- Custom extensions support

This configuration gives you a clean, fast launcher focused on productivity rather than feature discovery.
