{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Don Williams";
  gitEmail = "don.e.williams@gmail.com";

  # Hyprland Settings

  # Panel Choice - set to "hyprpanel" or "waybar"
  panelChoice = "waybar";

  # Glances Server - set to true to enable glances web server
  enableGlances = false;

  # Desktop Environment Options - set to true to enable
  gnomeEnable = false;
  bspwmEnable = false;
  dwmEnable = false;
  wayfireEnable = false;
  cosmicEnable = false;
  niriEnable = false;

  # Editor Options - set to true to enable
  enableEvilhelix = true;
  enableVscode = false;
  enableMicro = false;
  enableZed = false;

  # Terminal Options - set to true to enable
  enableAlacritty = true;
  enableTmux = true;
  enablePtyxis = true;
  enableWezterm = true;
  enableTwin = false;

  # OBS Studio
  enableObs = true;

  # Development Environment Options - set to true to enable
  enableDevEnv = true;

  # Display Manager Options
  # Toggle SDDM Wayland backend per host (default false)
  sddmWaylandEnable = false;

  # OpenCode CLI AI agent
  enableOpencode = false;

  #Zen Browser beta.
  enableZenBrowser = true;

  # Vicinae Launcher - set to true to enable
  enableVicinae = true;
  # Vicinae profile - options: "minimal", "standard", "developer", "power-user"
  vicinaeProfile = "power-user";

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "google-chrome-stable"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "ghostty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For hybrid support (Intel/NVIDIA Prime or AMD/NVIDIA)
  intelID = "PCI:1:0:0";
  amdgpuID = "PCI:5:0:0"; # placeholder; update per-host
  nvidiaID = "PCI:0:2:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = true;

  # Enable Thunar GUI File Manager
  thunarEnable = true;

  # Set Stylix Image
  stylixImage = ../../wallpapers/Anime-Purple-eyes.png;
  # Available options:
  #stylixImage = ../../wallpapers/Anime-Purple-eyes.png;
  #stylixImage = ../../wallpapers/mountainscapedark.jpg;
  #stylixImage = ../../wallpapers/zaney-wallpaper.jpg;
  #stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  #stylixImage = ../../wallpapers/nix-wallpaper-stripes-logo.png;
  #stylixImage = ../../wallpapers/beautifulmountainscape.jpg;
  #stylixImage = ../../wallpapers/Rainnight.jpg;

  # Set Waybar
  # Includes alternates such as:
  # Comment out the current choice and uncomment the one you want
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-mecha.nix;
  #waybarChoice = ../../modules/home/waybar/Jerry-waybars.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-tony.nix;
  waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-old-ddubsos.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-ml4w-modern.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-transparent.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-ultradark.nix;
  # ##  Oglo not finished yet, needs more work
  #AwaybarChoice = ../../modules/home/waybar/waybar-jak-oglo-simple.nix;

  # Set Starship prompt
  # Comment out the current choice and uncomment the one you want
  starshipChoice = ../../modules/home/cli/starship.nix;
  #starshipChoice = ../../modules/home/cli/starship-1.nix;
  #starshipChoice = ../../modules/home/cli/starship-rbmcg.nix;
  #starshipChoice = ../../modules/home/cli/starship-pC.nix;

  # Set Animation style
  # Available options are:
  # animations-def.nix  (default)
  # animations-end4.nix (end-4 project)
  # animations-end-slide.nix (end-4 mod'd to work with hyprtrails)
  # animations-dynamic.nix (ml4w project)
  #animChoice = ../../modules/home/hyprland/animations-end-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4.nix;
  #animChoice = ../../modules/home/hyprland/animations-def.nix;
  animChoice = ../../modules/home/hyprland/animations-dynamic.nix;
  # Moving does really weird things with window resize be warned
  #animChoice = ../../modules/home/hyprland/animations-moving.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";

  # Hyprland display configuration
  hyprMonitorsV2 = [
    {
      output = "HDMI-A-1";
      mode = "1920x1080@75";
      position = "auto";
      scale = 1;
      enabled = true;
    }
  ];

  extraMonitorSettings = "
    # monitor = HDMI-A-1,1920x1080@75,auto,1
  ";
}
