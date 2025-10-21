{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.nur.overlays.default
    (final: prev: {
      # Expose select packages from flake inputs through pkgs
      # so modules can depend only on pkgs and not on inputs.
      hyprpanel = inputs.hyprpanel.packages.${final.system}.default;
      ags = inputs.ags.packages.${final.system}.default;
      # Wrapper to expose AGS v1 binary as "agsv1" to allow parallel installs with newer AGS
      agsv1 = final.runCommand "agsv1" { nativeBuildInputs = [ final.makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper ${inputs.ags.packages.${final.system}.default}/bin/ags $out/bin/agsv1
      '';
      wfetch = inputs.wfetch.packages.${final.system}.default;
      quickshell = inputs.quickshell.packages.${final.system}.default;
      
      # Current Warp Terminal - gets updated via zcli update  
      # Use callPackage to properly handle unfree license
      # Enable waylandSupport to ensure Wayland libraries are included in runtime dependencies
      warp-terminal-current = final.callPackage "${inputs.warp-terminal-current}/warp/package.nix" { 
        waylandSupport = true;
      };
      
      # Create warp-bld executable as separate package to coexist with stable warp-terminal
      warp-bld = final.runCommand "warp-bld" {
        buildInputs = [ final.makeWrapper ];
        meta = final.warp-terminal-current.meta // {
          description = "Rust-based terminal (bleeding-edge version)";
        };
      } ''
        mkdir -p $out/bin
        
        # Create robust warp-bld wrapper with fallback error handling
        makeWrapper ${final.warp-terminal-current}/bin/warp-terminal $out/bin/warp-bld \
          --run 'if [[ "$XDG_SESSION_TYPE" == "wayland" ]] && [[ "$WARP_ENABLE_WAYLAND" != "0" ]]; then export WARP_ENABLE_WAYLAND=1; unset WINIT_UNIX_BACKEND; unset GDK_BACKEND; else export WINIT_UNIX_BACKEND=x11; export GDK_BACKEND=x11; export WARP_ENABLE_WAYLAND=0; fi'
        
        # Also create a direct compatibility symlink
        ln -s ${final.warp-terminal-current}/bin/warp-terminal $out/bin/warp-terminal-current
        
        # Copy other files from the original package
        if [ -d "${final.warp-terminal-current}/opt" ]; then
          cp -r ${final.warp-terminal-current}/opt $out/
        fi
        
        # Copy icons but create a distinct desktop entry for bleeding-edge
        if [ -d "${final.warp-terminal-current}/share/icons" ]; then
          mkdir -p $out/share
          cp -r ${final.warp-terminal-current}/share/icons $out/share/
        fi
        
        # Create a distinct desktop entry for the current build version
        mkdir -p $out/share/applications
        cat > $out/share/applications/dev.warp.Warp-bld.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Warp (Current bld)
GenericName=Terminal Emulator
Comment=Rust-based terminal (current upstream build)
Exec=warp-bld %U
StartupWMClass=dev.warp.Warp
Keywords=shell;prompt;command;commandline;cmd;current;latest;upstream;
Icon=dev.warp.Warp
Categories=System;TerminalEmulator;
Terminal=false
MimeType=x-scheme-handler/warp;
Actions=new-window;

[Desktop Action new-window]
Name=New Window
Exec=warp-bld
EOF
      '';
    })
  ];
}
