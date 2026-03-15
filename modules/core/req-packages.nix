{
  pkgs,
  stablePkgs,
  inputs,
  host,
  lib,
  ...
}: let
  hostVars = import ../../hosts/${host}/variables.nix;
  enableHyprlandSource = hostVars.enableHyprlandSource or false;

  system = pkgs.stdenv.hostPlatform.system;

  hyprlandPkg =
    if enableHyprlandSource
    then inputs.hyprland.packages.${system}.hyprland
    else pkgs.hyprland;

  hyprlandPortalPkg =
    if enableHyprlandSource
    then inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland
    else pkgs.xdg-desktop-portal-hyprland;
in {
  programs = {
    firefox.enable = false; # Firefox is not installed by default
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    hyprland = {
      enable = true;
      withUWSM = false; # Disabling for now.
      package = lib.mkForce hyprlandPkg;
      portalPackage = lib.mkForce hyprlandPortalPkg;
    };
    hyprlock.enable = true; # resolves pam issue
    xwayland.enable = true; # need for niri
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    #adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs;
    [
      hyprpanel # building from source for now (exposed through overlay)
      ags # for ags overview feature (exposed through overlay)
      agsv1 # wrapper binary for AGS v1 to run overview alongside newer AGS versions
      wfetch # custom fetch for nixos (exposed through overlay)
      #inputs.chaotic.packages.${pkgs.stdenv.hostPlatform.system}.beautyline-icons (not the ai-beautyline I want)

      ## Filesystem tools do not remove ##

      # Btrfs
      btrfs-progs
      # XFS
      xfsprogs
      # ssh test

      alejandra # nix formatter
      amfora # Fancy Terminal Browser For Gemini Protocol
      appimage-run # Needed For AppImage Support
      app2unit # launcher for noctalia
      atop # cli top utils like glances but better
      awww # Testing awww as replacement for swww
      bc # calc tool used to size windows or calc storage
      brightnessctl # For Screen Brightness Control
      cava # audio visualizer used by Waybar CAVA module
      below # htop like util and more
      blueman # Bluetooth manager (provides blueman-manager)
      boxbuddy # GUI to manage distrobox
      caligula # CLI tool to make bootable USBs
      chafa # Image preview for neovim
      clang # clang lib
      cmake # package builder
      cmatrix # Matrix Movie Effect In Terminal
      cliphist # clipboard history
      copilot-cli # AI terminal client
      cowsay # Great Fun Terminal Program
      ctop # top for docker containers
      ddcutil # brightness control for moniotrs
      discordo # TUI discord client
      distrobox # run other OSs in a container
      distrobox-tui # small gui to manage distrobox Use BoxBuddy for GUI
      direnv # Used by vscode
      docker-compose # Allows Controlling Docker From A Single File
      dry # docker container util
      dua # Disk Usage Analuzer
      duf # Utility For Viewing Disk Usage In Terminal
      dysk # cli util like df but better
      eog # For Image Viewing
      ethtool # Acceed network card HW
      eza # Beautiful ls Replacement
      fd # find command in rust
      file # determine file type
      ffmpeg # Terminal Video / Audio Editing
      file-roller # Archive Manager
      flac # for ffmpeg script from Zaney
      frogmouth # MD terminal browser
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
      gping # graphical ping
      gpu-screen-recorder # record screen for quickshell shells
      gimp # Great Photo Editor
      mesa-demos # (*renamed from glxinfo*) for inxi video info
      grimblast # needed for screenshots
      htop # Simple Terminal Based System Monitor
      inxi # CLI System Information Tool
      jq # Needed for HyprpanelA
      just # util like zcli but more general
      killall # For Killing All Instances Of Programs
      kmon # kernel monitor
      lazygit # TUI for git repo info
      lazyjournal # TUI for journalctl and docker
      libsecret # lib for storing keys
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
      microsoft-edge
      mpv # Incredible Video Player
      mpvpaper # wallpaper tool supports videos
      ncdu # Disk Usage Analyzer With Ncurses Interface
      ncftp # FTP Client
      nchat # Telegram / Whatsapp TUI client
      netcat # network utill
      nethogs # TUI monitor network IO per process
      nil # nix lsp
      nixd # nix language parser
      nitch # fetch
      nixfmt-rfc-style # Nix Formatter
      ntfs3g # mount NTFS  disks RW
      nodejs
      nix-tree # NixOS tool for nixstore
      pandoc # convert docs
      parted # needed for nix-iso building
      pavucontrol # For Editing Audio Levels & Devices
      pciutils # Collection Of Tools For Inspecting PCI Devices
      pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
      playerctl # Allows Changing Media Volume Through Scripts
      polkit_gnome # Needed for niri and wayfire
      qbittorrent # Torrent client
      qt6.qtimageformats # support image formats
      onefetch # CLI tool to show git repo info
      openssl # needed for backup client
      #oxker # TUI for docker containers
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
      shellcheck # for shell syntax checking
      sshpass # for non-interactive logins
      sox # for ffmpeg script from Zaney
      socat # Needed For Screenshots
      swaybg # Wallpaper setter, used as waypaper backend fallback
      tig # TUI for GIT
      ttop # TUI for system monitoring
      trippy # mtr with tui and history
      tuifimanager # termux style file manager
      ugrep # Improved grep
      unrar # Tool For Handling .rar Files
      unzip # Tool For Handling .zip Files
      usbutils # Good Tools For USB Devices
      v4l-utils # Used For Things Like OBS Virtual Camera
      viu # image previewer for Neovim
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
      zellij # Term mux like tmux
      zig # Popular compiler

      # Python runtime for Waybar Weather.py and other tools
      (python3.withPackages (ps: [ps.requests]))
    ]
    ++ (with pkgs.wayfirePlugins; [
      wcm
      wf-shell
    ]);
}
