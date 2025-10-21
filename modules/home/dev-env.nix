{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dev-env;
in
{
  options.programs.dev-env = {
    enable = mkEnableOption "development environment tools and configuration";

    enableDirectivIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable direnv shell integration for automatic environment loading";
    };

    enableCachix = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Cachix binary cache for faster devenv builds";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional development packages to install globally";
      example = literalExpression "with pkgs; [ docker-compose kubernetes-helm terraform ]";
    };
  };

  config = mkIf cfg.enable {
    # Enable direnv for automatic environment loading
    programs.direnv = mkIf cfg.enableDirectivIntegration {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    # Development packages with comprehensive C/X11 support
    home.packages = with pkgs; [
      # Core development tools for dev environments
      devenv          # devenv CLI (installed only when dev-env is enabled)

      # Additional useful development tools
      nix-direnv      # Better direnv + nix integration
      pre-commit      # Git pre-commit hooks
      act            # Run GitHub Actions locally
      gh             # GitHub CLI
      
      # Language servers and tools that work well with devenv
      nil            # Nix LSP
      nixpkgs-fmt    # Nix formatter
      
      # Container and virtualization tools
      podman         # Container runtime
      buildah        # Container builder
      
      # Additional development utilities
      jless          # JSON viewer
      fx             # JSON processor
      yq             # YAML/JSON processor
      
      # ═══════════════════════════════════════════════════════════════
      # C/C++ Development & Compilation Tools
      # ═══════════════════════════════════════════════════════════════
      
      # Essential build tools
      gcc            # GNU Compiler Collection
      clang          # LLVM C/C++ compiler
      gnumake        # GNU Make build system
      cmake          # Cross-platform build system
      meson          # Modern build system
      ninja          # Small build system focused on speed
      pkg-config     # Package configuration tool
      autoconf       # Automatic configure script builder
      automake       # Tool for automatically generating Makefile.in
      libtool        # Generic library support script
      
      # Debugging and analysis tools
      gdb            # GNU Debugger
      valgrind       # Memory debugging and profiling
      strace         # System call tracer
      ltrace         # Library call tracer
      
      # ═══════════════════════════════════════════════════════════════
      # X11/Wayland Development Libraries & Headers
      # ═══════════════════════════════════════════════════════════════
      
      # Core X11 libraries (essential for dwm, st, slstatus)
      xorg.libX11                    # Core X11 client library
      xorg.libXext                   # X11 extensions library
      xorg.libXft                    # X FreeType library (font rendering)
      xorg.libXinerama               # Xinerama extension (multi-monitor)
      xorg.libXrandr                 # X RandR extension (display config)
      xorg.libXrender                # X Render extension
      xorg.libXScrnSaver             # X Screen Saver extension
      xorg.libXcursor                # X cursor management
      xorg.libXdmcp                  # X Display Manager Control Protocol
      xorg.libXmu                    # X11 miscellaneous utilities
      xorg.libXpm                    # X11 pixmap library
      xorg.libXres                   # X-Resource extension
      xorg.libXtst                   # X11 testing extensions
      xorg.libXv                     # X11 Video extension
      xorg.libXxf86vm                # XFree86 video mode extension
      
      # Development headers for X11 libraries
      xorg.libX11.dev
      xorg.libXext.dev
      xorg.libXft.dev
      xorg.libXinerama.dev
      xorg.libXrandr.dev
      xorg.libXrender.dev
      
      # Font libraries (required for st and other text rendering)
      fontconfig                     # Font configuration and customization
      fontconfig.dev                 # Font config development headers
      freetype                       # Font rendering library
      freetype.dev                   # FreeType development headers
      harfbuzz                       # Text shaping library
      harfbuzz.dev                   # HarfBuzz development headers
      
      # Additional graphics libraries
      cairo                          # 2D graphics library
      cairo.dev                      # Cairo development headers
      pango                          # Text layout library
      pango.dev                      # Pango development headers
      
      # ═══════════════════════════════════════════════════════════════
      # Additional Libraries for Suckless Tools
      # ═══════════════════════════════════════════════════════════════
      
      # Libraries commonly used by dwm patches and extensions
      imlib2                         # Image loading library
      imlib2.dev                     # Imlib2 development headers
      
      # Audio libraries (for volume controls in slstatus/dwmblocks)
      alsa-lib                       # ALSA sound library
      alsa-lib.dev                   # ALSA development headers
      pulseaudio                     # PulseAudio sound system
      
      # Network libraries (for network monitoring in slstatus)
      curl                           # HTTP client library
      curl.dev                       # cURL development headers
      
      # System libraries
      systemd                        # systemd libraries
      systemd.dev                    # systemd development headers
      
      # ═══════════════════════════════════════════════════════════════
      # Development Tools & Utilities
      # ═══════════════════════════════════════════════════════════════
      
      # Text editors for code editing
      vim                            # Vi improved editor
      neovim                         # Modern vim fork
      
      # Version control
      git                            # Distributed version control
      
      # Archive and compression tools
      gzip                           # GNU zip compression
      tar                            # Tape archiver
      unzip                          # ZIP archive extractor
      
      # Text processing utilities
      gnused                         # GNU stream editor
      gawk                           # GNU awk
      gnugrep                        # GNU grep
      
      # File management tools
      findutils                      # GNU find utilities
      coreutils                      # GNU core utilities
      
      # Process management
      procps                         # Process utilities (ps, top, etc.)
      htop                           # Interactive process viewer
      
      # ═══════════════════════════════════════════════════════════════
      # Language-specific Development Tools
      # ═══════════════════════════════════════════════════════════════
      
      # Shell scripting
      shellcheck                     # Shell script linter
      shfmt                          # Shell script formatter
      
      # Documentation tools
      man-pages                      # Manual pages
      man-pages-posix               # POSIX manual pages
      
      # X11 utilities for testing
      xorg.xrandr                   # Display configuration
      xorg.xdpyinfo                 # Display information
      xorg.xwininfo                 # Window information
      xorg.xprop                    # Window properties
      
    ] ++ cfg.extraPackages
      ++ lib.optionals cfg.enableCachix [ pkgs.cachix ];

    # Note: cachix is included in packages above when enabled
    # No additional configuration needed - cachix works as a CLI tool

    # Shell aliases for common development operations
    home.shellAliases = {
      denv = "devenv";
      denv-init = "devenv init";
      denv-shell = "devenv shell";
      denv-up = "devenv up";
      denv-info = "devenv info";
      denv-gc = "devenv gc";
      
      # C development aliases
      mclean = "make clean";
      mbuild = "make clean && make";
      minstall = "make clean install";
      mdebug = "make clean && make CC='gcc -g -O0'";
      
      # Suckless tools aliases
      dwm-build = "cd ~/suckless/dwm && make clean && make";
      dwm-install = "cd ~/suckless/dwm && make clean install";
      st-build = "cd ~/suckless/st && make clean && make";
      st-install = "cd ~/suckless/st && make clean install";
      slstatus-build = "cd ~/suckless/slstatus && make clean && make";
      slstatus-install = "cd ~/suckless/slstatus && make clean install";
      
      # Development utilities
      checkdeps = "pkg-config --exists x11 xft xext xinerama xrandr fontconfig freetype2 && echo 'All X11 deps found' || echo 'Missing X11 dependencies'";
      xinfo = "xdpyinfo | head -20";
      xwinlist = "xwininfo -tree -root | grep -E '\\(|children:'";
    };

    # Create a basic suckless development environment template
    home.file.".local/share/devenv-templates/suckless-basic/devenv.nix".text = ''
      # Basic C/X11 development environment for suckless tools
      # Copy this to your dwm/st/slstatus directory and run: direnv allow

      { pkgs, ... }:
      {
        env = {
          CC = "gcc";
          PKG_CONFIG_PATH = with pkgs; lib.concatStringsSep ":" [
            "''${xorg.libX11.dev}/lib/pkgconfig"
            "''${xorg.libXft.dev}/lib/pkgconfig"
            "''${xorg.libXext.dev}/lib/pkgconfig"
            "''${fontconfig.dev}/lib/pkgconfig"
            "''${freetype.dev}/lib/pkgconfig"
          ];
        };

        packages = with pkgs; [
          gcc gnumake pkg-config
          xorg.libX11 xorg.libX11.dev
          xorg.libXft xorg.libXft.dev
          xorg.libXext xorg.libXext.dev
          xorg.libXinerama xorg.libXinerama.dev
          fontconfig fontconfig.dev
          freetype freetype.dev
          git vim
        ];

        scripts = {
          build.exec = "make clean && make";
          install.exec = "make clean install";
          check.exec = "pkg-config --exists x11 xft && echo 'Ready to build!'";
        };

        enterShell = '''
          echo "🔨 Suckless C Development Environment"
          echo "Available: devenv build, devenv install, devenv check"
        ''';
      }
    '';

    # Create basic .envrc example
    home.file.".local/share/devenv-templates/.envrc-example".text = ''
      # Add this content to your project's .envrc file
      # Then run: direnv allow

      use devenv

      # Optional: Load additional environment variables
      # dotenv_if_exists .env.local
    '';
  };
}