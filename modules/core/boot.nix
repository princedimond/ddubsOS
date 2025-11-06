{ pkgs
, config
, lib
, ...
}: {
  boot = {
    # Prefer CachyOS kernel for broad compatibility and matching ZFS variants
    kernelPackages = pkgs.linuxPackages_cachyos;

    # If ZFS is used, ensure we use the matching ZFS package for the selected kernel
    zfs.package = lib.mkOverride 99 pkgs.zfs_cachyos;

    kernelModules = [ "v4l2loopback" ];
    # Build v4l2loopback with GCC to match the kernel compiler
    # CachyOS kernel was built with GCC 14.3.0, so we must use GCC for module compatibility
    extraModulePackages = [
      (
        config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
          outputs = [ "out" ];
          # Use GCC to match kernel compiler - no stdenv override needed
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.gcc pkgs.binutils ];
          # Clear problematic environment variables
          NIX_CFLAGS_COMPILE = "";
          # Use standard GCC toolchain
          preBuild = ''
            # Ensure GCC is used to match kernel compiler
            export CC=gcc
            export LD=ld
            export HOSTCC=gcc
            export HOSTLD=ld
          '';
          # Standard make flags without LLVM
          makeFlags = (old.makeFlags or []) ++ [
            "CC=gcc"
            "LD=ld"
            "HOSTCC=gcc"
            "HOSTLD=ld"
          ];
          # Only install the kernel module; skip userspace utils entirely
          installPhase = ''
            runHook preInstall
            make -C ${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build \
              M=$PWD INSTALL_MOD_PATH=$out \
              CC=gcc \
              LD=ld \
              HOSTCC=gcc \
              HOSTLD=ld \
              modules_install
            runHook postInstall
          '';
          # Ensure any upstream postInstall that tries to install utils is disabled
          postInstall = ":";
        })
      )
    ];
    kernel.sysctl = { "vm.max_map_count" = 2147483642; };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    plymouth.enable = false;
  };
}
