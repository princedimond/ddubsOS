# Vicinae Launcher Configuration Module
# A high-performance native launcher for Linux
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) vicinaeProfile;
in
{
  # Import the upstream Home Manager module
  imports = [ inputs.vicinae.homeManagerModules.default ];

  # Configure based on profile from variables
  services.vicinae = {
    enable = true;
    package = inputs.vicinae.packages.${pkgs.system}.default;
    autoStart = true;
    useLayerShell = true;
    
    # Profile-based settings
    settings = lib.mkMerge [
      # Base settings for all profiles
      {
        theme.name = "vicinae-dark";
        window = {
          csd = true;
          opacity = 0.95;
          rounding = 16;  # Rounded corners for modern look
        };
        
        # Disable unwanted default items
        builtins = {
          # Disable store/marketplace features
          store = {
            enabled = false;
            showInRootSearch = false;
          };
          
          # Disable documentation links
          documentation = {
            enabled = false;
            showInRootSearch = false;
          };
          
          # Disable sponsor/funding related items
          sponsor = {
            enabled = false;
            showInRootSearch = false;
          };
          
          # Disable theme browser/manager if not needed
          themeManager = {
            enabled = false;
            showInRootSearch = false;
          };
          
          # Disable extension store browser
          extensionStore = {
            enabled = false;
            showInRootSearch = false;
          };
          
          # Keep useful builtins enabled
          applications = {
            enabled = true;
            showInRootSearch = true;
          };
          
          system = {
            enabled = true;
            showInRootSearch = true;
          };
        };
        
        # Configure root search to be cleaner
        rootSearch = {
          # Hide built-in items we don't want
          hiddenBuiltins = [
            "store"
            "documentation" 
            "sponsor"
            "themeManager"
            "extensionStore"
            "raycast-store"
            "manage-extensions"
            "get-help"
            "report-bug"
          ];
          
          # Show only relevant items
          enabledBuiltins = [
            "applications"
            "system"
            "calculator"
            "clipboard-history"
            "shortcuts"
          ];
        };
      }
      
      # Minimal profile
      (lib.mkIf (vicinaeProfile == "minimal") {
        rootSearch.searchFiles = false;
        clipboardHistory.enabled = false;
        extensions.raycast.enabled = false;
      })
      
      # Standard profile (default)
      (lib.mkIf (vicinaeProfile == "standard") {
        rootSearch.searchFiles = true;
        clipboardHistory = {
          enabled = true;
          maxItems = 500;
        };
        extensions.raycast.enabled = false;
      })
      
      # Developer profile
      (lib.mkIf (vicinaeProfile == "developer") {
        rootSearch.searchFiles = true;
        clipboardHistory = {
          enabled = true;
          maxItems = 1000;
        };
        calculator.enabled = true;
        shortcuts.enabled = true;
        extensions.raycast.enabled = true;
        # Optimize for coding workflows
        searchDelay = 50; # Faster response
        maxResults = 20;
      })
      
      # Power user profile  
      (lib.mkIf (vicinaeProfile == "power-user") {
        rootSearch = {
          searchFiles = true;
          indexHidden = true;
          maxFileResults = 50;
        };
        clipboardHistory = {
          enabled = true;
          maxItems = 2000;
          indexContent = true;
        };
        calculator = {
          enabled = true;
          precision = 10;
          history = true;
        };
        shortcuts = {
          enabled = true;
          smartLinks = true;
        };
        extensions = {
          raycast.enabled = true;
          customExtensions = true;
        };
        # Performance optimizations
        searchDelay = 25;
        maxResults = 50;
        prefetchResults = true;
      })
    ];
    
    # Example ddubsos theme
    themes."ddubsos-theme" = {
      version = "1.0.0";
      appearance = "dark";
      name = "ddubsOS Theme";
      description = "Default theme for ddubsOS";
      palette = {
        background = "#1a1a1a";
        foreground = "#e0e0e0";
        blue = "#61afef";
        green = "#98c379";
        magenta = "#c678dd";
        orange = "#d19a66";
        red = "#e06c75";
        yellow = "#e5c07b";
        cyan = "#56b6c2";
      };
    };
  };

  # Add to user packages for CLI access
  home.packages = [ inputs.vicinae.packages.${pkgs.system}.default ];

  # Additional configuration notes:
  # - Some Vicinae settings may require manual adjustment in ~/.config/vicinae/vicinae.json
  # - Built-in items can be disabled through the UI or by editing the config file
  # - Use 'vicinae --help' for CLI options and debugging

  # Create desktop entry for manual launch
  xdg.desktopEntries.vicinae = {
    name = "Vicinae";
    comment = "High-performance native launcher";
    exec = "${lib.getExe inputs.vicinae.packages.${pkgs.system}.default}";
    icon = "vicinae";
    type = "Application";
    categories = [ "Utility" "Accessibility" ];
    startupNotify = true;
  };
}
