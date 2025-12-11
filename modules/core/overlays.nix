{inputs, ...}: {
  nixpkgs.overlays = [
    #inputs.nur.overlays.default
    # Provide pkgs.google-antigravity via antigravity-nix overlay
    inputs.antigravity-nix.overlays.default
    (final: prev: {
      # Expose select packages from flake inputs through pkgs
      # so modules can depend only on pkgs and not on inputs.
      #ags = inputs.ags.packages.${final.stdenv.hostPlatform.system}.default;
      hyprpanel = inputs.hyprpanel.packages.${final.stdenv.hostPlatform.system}.default;
      # Wrapper to expose AGS v1 (pinned via inputs.agsv1) as "agsv1" so it can coexist with latest AGS versions
      agsv1 = final.runCommand "agsv1" {nativeBuildInputs = [final.makeWrapper];} ''
        mkdir -p $out/bin
        makeWrapper ${inputs.agsv1.packages.${final.stdenv.hostPlatform.system}.default}/bin/ags $out/bin/agsv1
      '';
      wfetch = inputs.wfetch.packages.${final.stdenv.hostPlatform.system}.default;
      # Prefer rio from nixpkgs to avoid upstream flake Rust toolchain build failures
      #rio = prev.rio;
      awww = inputs.awww.packages.${final.stdenv.hostPlatform.system}.default;
      # OXWM (X11 tiling WM) from its flake input, exposed as pkgs.oxwm
      oxwm = inputs.oxwm.packages.${final.stdenv.hostPlatform.system}.oxwm;

      # Temporary hotfix: disable tests for docker-language-server due to upstream failures
      "docker-language-server" = prev."docker-language-server".overrideAttrs (old: {
        doCheck = false;
      });

      # Specifically patch the nested attribute path used by nixpkgs: antlr4_9.runtime.cpp
      # This replaces the passthru runtime.cpp derivation with one that adds the policy flag
      antlr4_9 =
        prev.antlr4_9
        // {
          runtime =
            prev.antlr4_9.runtime
            // {
              cpp = prev.antlr4_9.runtime.cpp.overrideAttrs (old: {
                cmakeFlags =
                  (old.cmakeFlags or [])
                  ++ [
                    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
                  ];
                postPatch =
                  (old.postPatch or "")
                  + ''
                    # Bump CMake minimum to satisfy modern CMake policy checks
                    if [ -f runtime/Cpp/runtime/CMakeLists.txt ]; then
                      sed -i -E 's/cmake_minimum_required\(VERSION [0-9.]+\)/cmake_minimum_required(VERSION 3.5)/' runtime/Cpp/runtime/CMakeLists.txt
                      # Modern CMake forbids setting OLD for many policies; force NEW instead
                      sed -i -E 's/(cmake_policy\(SET CMP[0-9]+ )OLD/\1NEW/g' runtime/Cpp/runtime/CMakeLists.txt || true
                      sed -i -E 's/(CMAKE_POLICY\(SET CMP[0-9]+ )OLD/\1NEW/g' runtime/Cpp/runtime/CMakeLists.txt || true
                    fi
                    if [ -f runtime/Cpp/CMakeLists.txt ]; then
                      sed -i -E 's/cmake_minimum_required\(VERSION [0-9.]+\)/cmake_minimum_required(VERSION 3.5)/' runtime/Cpp/CMakeLists.txt
                      sed -i -E 's/(cmake_policy\(SET CMP[0-9]+ )OLD/\1NEW/g' runtime/Cpp/CMakeLists.txt || true
                      sed -i -E 's/(CMAKE_POLICY\(SET CMP[0-9]+ )OLD/\1NEW/g' runtime/Cpp/CMakeLists.txt || true
                    fi
                  '';
              });
            };
        };

      # Current Warp Terminal - gets updated via zcli update
      # Use callPackage to properly handle unfree license
      # Enable waylandSupport to ensure Wayland libraries are included in runtime dependencies
      warp-terminal-current = final.callPackage ../../pkgs/warp-terminal-current/package.nix {
        waylandSupport = true;
      };
      # Create warp-bld executable as separate package to coexist with stable warp-terminal
      warp-bld =
        final.runCommand "warp-bld"
        {
          buildInputs = [final.makeWrapper];
          meta =
            final.warp-terminal-current.meta
            // {
              description = "Rust-based terminal (bleeding-edge version)";
            };
        } ''
                  mkdir -p $out/bin

                  # Create robust warp-bld wrapper with fallback error handling
                  makeWrapper ${final.warp-terminal-current}/bin/warp-terminal $out/bin/warp-bld \
                    --run 'if [[ "$XDG_SESSION_TYPE" == "wayland" ]] && [[ "$WARP_ENABLE_WAYLAND" != "0" ]] ; then export WARP_ENABLE_WAYLAND=1; unset WINIT_UNIX_BACKEND; unset GDK_BACKEND; else export WINIT_UNIX_BACKEND=x11; export GDK_BACKEND=x11; export WARP_ENABLE_WAYLAND=0; fi'

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
