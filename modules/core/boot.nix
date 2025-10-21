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
    # Build v4l2loopback with the same (LLVM) toolchain as the CachyOS kernel
    # by passing LLVM=1 to Kbuild. This avoids 'gcc: command not found' when the
    # kernel was built with clang.
    extraModulePackages = [
      (
        (config.boot.kernelPackages.v4l2loopback.override {
          stdenv = pkgs.llvmPackages.stdenv;
        }).overrideAttrs (old: {
          outputs = [ "out" ];
          # Use unwrapped clang/lld to avoid nix cc-wrapper injecting unsupported flags
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.llvmPackages.clang-unwrapped pkgs.llvmPackages.lld ];
          # Export CC/LD/LLVM in the build environment to ensure Kbuild picks clang/lld
          CC = "${pkgs.llvmPackages.clang-unwrapped}/bin/clang";
          LD = "${pkgs.llvmPackages.lld}/bin/ld.lld";
          LLVM = "1";
          # Suppress unused-command-line-argument errors from kernel CFLAGS when using clang
          makeFlags = (old.makeFlags or []) ++ [
            "LLVM=1"
            "CC=${pkgs.llvmPackages.clang-unwrapped}/bin/clang"
            "LD=${pkgs.llvmPackages.lld}/bin/ld.lld"
            "EXTRA_CFLAGS=-Wno-error=unused-command-line-argument -Wno-unused-command-line-argument"
          ];
          # Only install the kernel module; skip userspace utils entirely
          installPhase = ''
            runHook preInstall
            make -C ${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build \
              M=$PWD INSTALL_MOD_PATH=$out modules_install
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
