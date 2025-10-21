{inputs, ...}: {
  imports = [
    # Chaotic Nyx: provides CachyOS kernel packages and ZFS variants
    inputs.chaotic.nixosModules.default

    ./boot.nix
    ./cachix.nix
    ./flatpak.nix
    ./fonts.nix
    ./glances-server.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./req-packages.nix
    ./global-packages.nix
    ./printing.nix
    #./quickshell.nix
    ./sddm.nix
    ./ly.nix
    ./security.nix
    ./session-env.nix
    ./services.nix
    ./steam.nix
    ./stylix.nix
    ./syncthing.nix
    ./system.nix
    ./thunar.nix
    ./user.nix
    ./virtualisation.nix
    ./xserver.nix
    inputs.stylix.nixosModules.stylix
    
    # Apps modules
    ../apps/warp-terminal-current.nix
  ];
  
  # Enable warp-terminal-current globally on all hosts
  programs.warp-terminal-current.enable = true;

  # Avoid building userland utils for v4l2loopback inside the kernel-module derivation.
  # Upstream Makefile contains a utils/ tool (v4l2loopback-ctl) that requires glibc, which
  # isn't available in the kernel build environment. This overlay trims the buildPhase to
  # only build the kernel module for both linuxPackages and linuxPackages_cachyos.
  nixpkgs.overlays = [
    (final: prev: {
      # Standalone userspace tool build from the same v4l2loopback source
      v4l2loopbackCtl = prev.stdenv.mkDerivation {
        pname = "v4l2loopback-ctl";
        version = "0.15.1";
        # Reuse the source from the CachyOS kernel set if available, otherwise default linuxPackages
        src = (prev.linuxPackages_cachyos.v4l2loopback.src or prev.linuxPackages.v4l2loopback.src);
        nativeBuildInputs = [ ];
        buildInputs = [ prev.linuxHeaders ];
        buildPhase = ''
          runHook preBuild
          make -C utils V4L2LOOPBACK_SNAPSHOT_VERSION=
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          install -Dm755 utils/v4l2loopback-ctl $out/bin/v4l2loopback-ctl
          runHook postInstall
        '';
        meta = with prev.lib; {
          description = "Control utility for v4l2loopback kernel module";
          homepage = "https://github.com/umlaeute/v4l2loopback";
          license = licenses.gpl2Plus;
          platforms = platforms.linux;
        };
      };

      linuxPackages = prev.linuxPackages.extend (lpFinal: lpPrev: {
        v4l2loopback = lpPrev.v4l2loopback.overrideAttrs (old: {
          buildPhase = ''
            make ''${makeFlags[@]} -C ${lpPrev.kernel.dev}/lib/modules/${lpPrev.kernel.modDirVersion}/build \
              M=$PWD KCPPFLAGS="" modules
          '';
          installPhase = ''
            runHook preInstall
            make ''${makeFlags[@]} -C ${lpPrev.kernel.dev}/lib/modules/${lpPrev.kernel.modDirVersion}/build \
              M=$PWD modules_install INSTALL_MOD_PATH=$out
            runHook postInstall
          '';
          postBuild = ''
            :
          '';
        });
      });
      linuxPackages_cachyos = prev.linuxPackages_cachyos.extend (lpFinal: lpPrev: {
        v4l2loopback = lpPrev.v4l2loopback.overrideAttrs (old: {
          buildPhase = ''
            make ''${makeFlags[@]} -C ${lpPrev.kernel.dev}/lib/modules/${lpPrev.kernel.modDirVersion}/build \
              M=$PWD KCPPFLAGS="" modules
          '';
          installPhase = ''
            runHook preInstall
            make ''${makeFlags[@]} -C ${lpPrev.kernel.dev}/lib/modules/${lpPrev.kernel.modDirVersion}/build \
              M=$PWD modules_install INSTALL_MOD_PATH=$out
            runHook postInstall
          '';
          postBuild = ''
            :
          '';
        });
      });
    })
  ];

  # This override was done when dvdauthor failed to build
  # Disbling but leaving this in place in case it occurs again
  # Since more than once it has failed to build 7/30/25

  # nixpkgs.overlays = [
  #  (final: prev: {
  #    dvdauthor = prev.dvdauthor.overrideAttrs (oldAttrs: {
  #      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.gettext];
  #    });
  #  })
  #];
}
