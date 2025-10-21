{ pkgs, stablePkgs, ... }:
{
  programs = {
    firefox.enable = false; # Firefox is not installed by default
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    hyprland = {
      enable = true;
      withUWSM = false; # Disabling for now.
    };
    hyprlock.enable = true; # resolves pam issue
    xwayland.enable = true; # need for niri
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages =
    with pkgs;
    [

      hyprpanel # building from source for now (exposed through overlay)
      ags # for ags overview feature (exposed through overlay)
      agsv1 # wrapper binary for AGS v1 to run overview alongside newer AGS versions
      wfetch # custom fetch for nixos (exposed through overlay)
      #inputs.chaotic.packages.${pkgs.system}.beautyline-icons (not the ai-beautyline I want)

      ## Filesystem tools do not remove ##
      # ZFS
      zfs
      # bcachefs
      bcachefs-tools
      # Btrfs
      btrfs-progs
      # XFS
      xfsprogs

      amfora # Fancy Terminal Browser For Gemini Protocol
      atop # cli top utils like glances but better
      appimage-run # Needed For AppImage Support
      bc # calc tool used to size windows or calc storage
      brightnessctl # For Screen Brightness Control
      cava # audio visualizer used by Waybar CAVA module
      blueman # Bluetooth manager (provides blueman-manager)
      boxbuddy # GUI to manage distrobox
      caligula # CLI tool to make bootable USBs
      clang # clang lib
      cmake # package builder
      cmatrix # Matrix Movie Effect In Terminal
      copyq # cllipboard manager
      cowsay # Great Fun Terminal Program
      cliphist # clipboard history
      distrobox # run other OSs in a container
      distrobox-tui # small gui to manage distrobox Use BoxBuddy for GUI
      direnv # Used by vscode
      docker-compose # Allows Controlling Docker From A Single File
      dua # Disk Usage Analuzer
      duf # Utility For Viewing Disk Usage In Terminal
      dysk # cli util like df but better
      eog # For Image Viewing
      eza # Beautiful ls Replacement
      fd # find command in rust
      ffmpeg # Terminal Video / Audio Editing
      file-roller # Archive Manager
      flac # for ffmpeg script from Zaney
      gcc # C compiler
      gdb # debugger needed to triage warp terminal
      gdu # go disk usage
      gemini-cli # gemini AI @ CLI
      git # git cli tool
      glab # gitlab cli tool
      glances # cli monitor tool
      gnumake # make command
      gparted # needed for nix-iso building
      grim # needed for screenshots
      google-chrome
      gping # graphical ping
      gimp # Great Photo Editor
      glxinfo # for inxi video info
      grimblast # needed for screenshots
      htop # Simple Terminal Based System Monitor
      inxi # CLI System Information Tool
      jq # Needed for HyprpanelA
      just # util like zcli but more general
      killall # For Killing All Instances Of Programs
      lazygit # TUI for git repo info
      libnotify # For Notifications
      libva-utils # Utilities for GPUs
      libwebp # video processing library
      lm_sensors # Used For Getting Hardware Temps
      lolcat # Add Colors To Your Terminal Command Output
      lsof # list open files
      lshw # Detailed Hardware Information
      luarocks # lua support for nvim
      lua54Packages.luacheck # lua lint for nvim
      matugen # color palette generator needed for Hyprpanel
      mpv # Incredible Video Player
      mpvpaper # wallpaper tool supports videos
      ncdu # Disk Usage Analyzer With Ncurses Interface
      ncftp # FTP Client
      nitch
      nixfmt-rfc-style # Nix Formatter
      nixpkgs-fmt # Check compliance with NIX format std
      ntfs3g # mount NTFS  disks RW
      nodejs
      nix-tree # NixOS tool for nixstore
      pandoc
      parted # needed for nix-iso building
      pavucontrol # For Editing Audio Levels & Devices
      pciutils # Collection Of Tools For Inspecting PCI Devices
      pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
      playerctl # Allows Changing Media Volume Through Scripts
      polkit_gnome # Needed for niri and wayfire
      qbittorrent # Torrent client
      onefetch # CLI tool to show git repo info
      pulseaudioFull
      pulsemixer
      pyprland # provides drop down terminal in Hyprland
      power-profiles-daemon # set performanc, balanced, power saving mode
      rhythmbox # music player
      ripgrep # Improved Grep
      satty # part of screen capture
      serie # git history in terminal
      signal-desktop # signal chat client
      SDL # for older games
      slurp # uses for screenshots
      sox # for ffmpeg script from Zaney
      socat # Needed For Screenshots
      swaybg # Wallpaper setter, used as waypaper backend fallback
      ugrep # Improved grep
      unrar # Tool For Handling .rar Files
      unzip # Tool For Handling .zip Files
      usbutils # Good Tools For USB Devices
      v4l-utils # Used For Things Like OBS Virtual Camera
      v4l2loopbackCtl # standalone userspace tool for v4l2loopback
      vlc # VideoLan video player
      vulkan-tools # tools for video adapter info
      w3m # cli web client
      waypaper # Wallpaper selector
      waytrogen # Image dislay and wallpaper selector
      wget # Tool For Fetching Files With Links
      yazi # TUI File Manager
      ytmdl # Tool For Downloading Audio From YouTube
      youtube-music # music player for youtube
      virt-viewer # Needed for proxmox
      zig # Popular compiler

      # Python runtime for Waybar Weather.py and other tools
      (python3.withPackages (ps: [ ps.requests ]))
    ]
    ++ (with pkgs.wayfirePlugins; [
      wcm
      wf-shell
    ]);
}
