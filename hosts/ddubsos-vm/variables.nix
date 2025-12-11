{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Don Williams";
  gitEmail = "don.e.williams@gmail.com";

  # Hyprland Settings

  # Set to true if you want to build Hyprland from source instead of using nixpkgs version
  enableHyprlandSource = true;

  # Panel Choice - set to "hyprpanel", "waybar", "Noctalia"
  panelChoice = "noctalia";

  # Glances Server - set to true to enable glances web server
  enableGlances = false;

  # GUI Environment Options - set to true to enable
  gnomeEnable = false;
  bspwmEnable = false;
  i3Enable = true;
  dwmEnable = false;
  wayfireEnable = false;
  cosmicEnable = false;
  niriEnable = false;
  enableSway = false;
  enableMangowc = false;
  oxwmEnable = true;

  # Editor Options - set to true to enable
  # Enabling Nixvim disables NVF automatically.
  enableNixvim = true;
  enableEvilhelix = true;
  enableVscode = true;
  enableAntiGravity = true;
  enableMicro = false;
  enableZed = true;

  # Terminal Options - set to true to enable
  enableAlacritty = true;
  enableTmux = true;
  enablePtyxis = true;
  enableWezterm = true;
  enableRio = false;
  enableTwin = false;

  # OBS Studio
  enableObs = false;

  # Containers
  enableIncus = false;

  # Development Environment Options - set to true to enable
  enableDevEnv = false;

  # Display Manager Options
  # Toggle SDDM Wayland backend per host (default false)
  # Disabled for VM: SDDM Wayland mode causes boot hangs when hyprland is default session
  sddmWaylandEnable = true;

  # OpenCode CLI AI agent
  enableOpencode = false;

  #Zen Browser beta.
  enableZenBrowser = true;

  # Ladybird browser (unstable)
  enableLadybird = false;

  # Vicinae Launcher - set to true to enable
  enableVicinae = false;
  # Vicinae profile - options: "minimal", "standard", "developer", "power-user"
  vicinaeProfile = "minimal";

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "google-chrome"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "ghostty"; # Set Default System Terminal

  # wlroots VM quirks for compositors (Sway, etc.)
  wlrVmQuirks = false;
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Shell choice (per-host overrideable)
  shellChoice = "zsh"; # options: "zsh" | "bash" | "fish" | "nushell"

  # For hybrid support (Intel/NVIDIA Prime or AMD/NVIDIA)
  intelID = "PCI:1:0:0";
  amdgpuID = "PCI:5:0:0"; # placeholder; update per-host
  nvidiaID = "PCI:0:2:0";

  # Enable NFS
  enableNFS = true;

  # Folding@home (per-host)
  enableFoldingAtHome = false;
  foldingTeamId = 1066966; # PewDiePie team

  # Enable Printing Support
  printEnable = false;

  # Enable Thunar GUI File Manager
  thunarEnable = true;

  # Set Stylix Image
  #stylixImage = ../../wallpapers/Anime-Purple-eyes.png;
  #stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  stylixImage = ../../wallpapers/mountainscapedark.jpg;
  # Available options:
  #stylixImage = ../../wallpapers/Anime-Purple-eyes.png;
  #stylixImage = ../../wallpapers/mountainscapedark.jpg;
  #stylixImage = ../../wallpapers/zaney-wallpaper.jpg;
  #stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  #stylixImage = ../../wallpapers/nix-wallpaper-stripes-logo.png;
  #stylixImage = ../../wallpapers/beautifulmountainscape.jpg;
  #stylixImage = ../../wallpapers/Rainnight.jpg;

  # Set Waybar
  # Zaneyos includes an alternative waybars
  # Comment out the current choice and uncomment the one you want
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/Jerry-waybars.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  waybarChoice = ../../modules/home/waybar/waybar-tony.nix;
  # waybarChoice = ../../modules/home/waybar/waybar-mecha.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-old-ddubsos.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-pctrade-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-ml4w-modern.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-transparent.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-ultradark.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-TheBlackDon.nix;
  # ##  Oglo not finished yet, needs more work
  #AwaybarChoice = ../../modules/home/waybar/waybar-jak-oglo-simple.nix;

  # Set Starship prompt
  # Comment out the current choice and uncomment the one you want
  #starshipChoice = ../../modules/home/cli/starship.nix;
  #starshipChoice = ../../modules/home/cli/starship-1.nix;
  starshipChoice = ../../modules/home/cli/starship-catppuccin.nix;
  #starshipChoice = ../../modules/home/cli/starship-rbmcg.nix;
  #starshipChoice = ../../modules/home/cli/starship-pC.nix;

  # Set Animation style
  # Available options are:
  # animations-def.nix  (standard)
  # animations-end4.nix (end-4 project)
  # animations-end-slide.nix (end-4 mod'd to work with hyprtrails)
  # animations-dynamic.nix (ml4w project)
  # animations-moving.nix (ml4w project)
  # animations-hyde-optimized.nix (hyde optimized)
  # animations-ml4w-classic.nix (ml4w classic)
  # animations-mahaveer-me-1.nix (mahaveer me-1)
  # animations-mahaveer-me-2.nix (mahaveer me-2)
  # animations-ml4w-fast.nix (ml4w fast)
  # animations-ml4w-high.nix (ml4w high)
  # Comment out the current choice and uncomment the one you want
  #animChoice = ../../modules/home/hyprland/animations-def.nix;
  #animChoice = ../../modules/home/hyprland/animations-end-slide.nix;
  animChoice = ../../modules/home/hyprland/animations-end4.nix;
  #animChoice = ../../modules/home/hyprland/animations-dynamic.nix;
  # Moving does really weird things with window resize be warned
  #animChoice = ../../modules/home/hyprland/animations-moving.nix;
  #animChoice = ../../modules/home/hyprland/animations-hyde-optimized.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-classic.nix;
  #animChoice = ../../modules/home/hyprland/animations-mahaveer-me-1.nix;
  #animChoice = ../../modules/home/hyprland/animations-mahaveer-me-2.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-fast.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-high.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";

  # Hyprland display configuration
  hyprMonitorsV2 = [
    {
      output = "Virtual-1";
      mode = "1920x1080@60";
      position = "auto";
      scale = 1;
      enabled = true;
    }
  ];

  extraMonitorSettings = "
     monitor = Virtual-1,1920x1080@60,0x0,1
  ";
}
