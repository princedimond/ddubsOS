{ pkgs }:

{
  # Use nixpkgs dwm with custom source and config
  dwm = pkgs.dwm.overrideAttrs (oldAttrs: {
    src = ../dwm-setup/suckless/dwm;
    # Inherit version from our source, but fallback to nixpkgs version
    version = "6.4-custom";
    
    # Add any additional build inputs if needed beyond nixpkgs defaults
    buildInputs = oldAttrs.buildInputs or [] ++ (with pkgs; [
      # Add any extra dependencies your custom dwm needs
    ]);
    
    # Optional: Add patches during build if you want to apply them automatically
    # postPatch = oldAttrs.postPatch or "" + ''
    #   # Apply custom patches here if needed
    # '';
  });

  # Use nixpkgs st with custom source and config  
  st = pkgs.st.overrideAttrs (oldAttrs: {
    src = ../dwm-setup/suckless/st;
    version = "0.8.4-custom";
    
    # nixpkgs st already includes the right dependencies, but we can extend if needed
    buildInputs = oldAttrs.buildInputs or [] ++ (with pkgs; [
      # Add any extra dependencies your custom st needs beyond nixpkgs defaults
    ]);
    
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ (with pkgs; [
      # pkg-config is likely already included in nixpkgs st
    ]);
  });

  # Use nixpkgs slstatus with custom source and config
  slstatus = pkgs.slstatus.overrideAttrs (oldAttrs: {
    src = ../dwm-setup/suckless/slstatus;
    version = "1.0-custom";
    
    # Keep your custom static linking configuration
    buildInputs = oldAttrs.buildInputs or [] ++ (with pkgs.pkgsStatic; [
      xorg.libX11
      stdenv.cc.libc
      xorg.libxcb
      xorg.libXau
      xorg.libXdmcp
    ]);
    
    # Preserve your custom postPatch for static linking
    postPatch = (oldAttrs.postPatch or "") + ''
      sed -i 's/LDFLAGS  =.*/LDFLAGS = -static/' config.mk
      sed -i 's/LDLIBS   =.*/LDLIBS   = -lX11 -lxcb -lXau -lXdmcp/' config.mk
    '';
  });

  scripts = pkgs.stdenv.mkDerivation {
    pname = "suckless-scripts";
    version = "1.0";
    src = ../dwm-setup/suckless/scripts;
    installPhase = ''
      mkdir -p $out/bin
      cp -r * $out/bin/
    '';
  };
}
