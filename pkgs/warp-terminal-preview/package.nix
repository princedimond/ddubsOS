{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  file,
  zlib,
  libGL,
  libglvnd,
  curl,
  alsa-lib,
  xorg,
  libxkbcommon,
  wayland,
  gtk3,
  pango,
  cairo,
  fontconfig,
  freetype,
  libdrm,
  vulkan-loader,
}: let
  versions = lib.importJSON ./versions.json;
in
  stdenv.mkDerivation {
    pname = "warp-terminal-preview";
    version = versions.linux.version;

    src = fetchurl {
      url = "https://app.warp.dev/download?channel=preview&package=deb";
      sha256 = versions.linux.hash;
      curlOptsList = ["-L"];
      name = "warp-preview.deb";
    };

    nativeBuildInputs = [autoPatchelfHook dpkg makeWrapper file];
    buildInputs = [
      (lib.getLib stdenv.cc.cc)
      zlib
      libGL
      libglvnd
      curl
      alsa-lib
      xorg.libX11
      xorg.libXext
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libxcb
      libxkbcommon
      wayland
      gtk3
      pango
      cairo
      fontconfig
      freetype
      libdrm
      vulkan-loader
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share $out/libexec

      # Copy vendor assets if present
      if [ -d usr/share ]; then
        cp -r usr/share/* $out/share/ || true
      fi

      # Copy payload directory
      if [ -d opt/warpdotdev/warp-terminal-preview ]; then
        cp -r opt/warpdotdev/warp-terminal-preview $out/libexec/
      elif [ -d opt/warpdotdev/warp-preview ]; then
        cp -r opt/warpdotdev/warp-preview $out/libexec/
      fi

      # Find the actual preview binary
      target=""
      for cand in \
        "$out/libexec/warp-preview" \
        "$out/libexec/warp-terminal-preview/warp-preview" \
        "$out/libexec/warp-terminal-preview/warp" \
        "$out/libexec/warp-preview/warp"; do
        if [ -x "$cand" ]; then target="$cand"; break; fi
      done

      if [ -z "$target" ]; then
        echo "Could not locate warp-preview binary inside deb payload" >&2
        ls -R "$out/libexec" >&2 || true
        exit 1
      fi

      makeWrapper "$target" "$out/bin/warp-preview" \
        --prefix PATH : /run/wrappers/bin \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libGL
        libglvnd
        libxkbcommon
        wayland
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        xorg.libxcb
        vulkan-loader
        libdrm
        (lib.getLib stdenv.cc.cc)
      ]} \
        --set-default WARP_ENABLE_WAYLAND 1 \
        --set-default FONTCONFIG_FILE ${fontconfig}/etc/fonts/fonts.conf \
        --set-default XDG_DATA_DIRS ${lib.makeSearchPath "share" [gtk3 fontconfig]}:"/usr/local/share:/usr/share"

      # Normalize desktop Exec lines to our wrapper
      if [ -d "$out/share/applications" ]; then
        for d in "$out/share/applications/"*.desktop; do
          [ -f "$d" ] || continue
          sed -i "s|^Exec=.*|Exec=$out/bin/warp-preview|" "$d" || true
        done
      fi
    '';

    meta = with lib; {
      description = "Warp Terminal (preview channel) packaged from vendor .deb";
      platforms = platforms.linux;
      license = licenses.unfree;
    };
  }
