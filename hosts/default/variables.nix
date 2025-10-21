{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Don Williams";
  gitEmail = "don.e.williams@gmail.com";

  # Panel Choice - set to "hyprpanel" or "waybar"
  # If you chose waybar you can select from different cfgs
  # Farther down in this file
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

  # Window manager options
  enableNiri = false;

  # Editor Options - set to true to enable
  enableEvilhelix = false;
  enableVscode = false;
  enableMicro = false;
  enableZed = false;

  # Terminal Options - set to true to enable
  enableAlacritty = false;
  enableTmux = false;
  enablePtyxis = false;
  enableWezterm = false;
  enableTwin = false; # Text-mode window environment (twin)

  # OBS Studio
  # If you enable this here, comment it out
  # in modules/core/flatpak.nix
  # The flatpak is the offically supported package
  # Often it will work better with NVIDIA/AMD for decoding
  enableObs = false;

  # Development Environment Options - set to true to enable
  enableDevEnv = false;

  # Display Manager Options
  # Toggle SDDM Wayland backend per host. When false, SDDM uses X11.
  # Set to true on hosts (e.g., NVIDIA laptops) where SDDM only starts with Wayland.
  sddmWaylandEnable = false;

  # OpenCode CLI AI agent
  enableOpencode = false;

  # Zen Browser beta.
  enableZenBrowser = false;

  # Vicinae Launcher - set to true to enable
  enableVicinae = false;
  # Vicinae profile - options: "minimal", "standard", "developer", "power-user"
  vicinaeProfile = "standard";

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "google-chrome-stable"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "ghostty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For hybrid support (Intel/NVIDIA Prime or AMD/NVIDIA)
  intelID = "PCI:1:0:0";
  amdgpuID = "PCI:5:0:0";
  nvidiaID = "PCI:0:2:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = true;

  # Enable Thunar GUI File Manager
  thunarEnable = true;

  # Set Stylix Image
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
  # Includes alternates such as:
  # Comment out the current choice and uncomment the one you want
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/Jerry-waybars.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-mecha.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  waybarChoice = ../../modules/home/waybar/waybar-tony.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-old-ddubsos.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin.nix;
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
  # animations-def.nix  (standard)
  # animations-end4.nix (end-4 project)
  # animations-end4-slide.nix (end-4 mod'd to work with hyprtrails)
  # animations-dynamic.nix (ml4w project)
  # animations-moving.nix (ml4w project)
  # Comment out the current choice and uncomment the one you want
  #animChoice = ../../modules/home/hyprland/animations-def.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4.nix;
  animChoice = ../../modules/home/hyprland/animations-dynamic.nix;
  # Moving does really weird things with window resize be warned
  #animChoice = ../../modules/home/hyprland/animations-moving.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";

  # Hyprland display configuration (monitorv2 preferred; legacy string kept commented for reference)
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
    # monitor = Virtual-1, 1920x1080@60,auto,1
  ";

  # Example: Structured legacy monitors (render to `monitor =` lines)
  # Uncomment and adapt when the module supports hyprMonitors
  # hyprMonitors = [
  #   {
  #     name = "DP-1";        # alias: output
  #     mode = "2560x1440@144";
  #     position = "0x0";
  #     scale = 1;
  #     enabled = true;       # when false, would render as: monitor = DP-1, disable
  #   }
  #   {
  #     name = "HDMI-A-1";
  #     mode = "1920x1080@60";
  #     position = "2560x0";  # to the right of DP-1
  #     scale = 1.25;
  #     enabled = true;
  #   }
  # ];

  # Example: monitorv2 blocks (preferred for Hyprland)
  # Uncomment and adapt when the module supports hyprMonitorsV2
  #
  # Transform values (wl_output_transform):
  #   0=normal, 1=90, 2=180, 3=270, 4=flipped, 5=flipped-90, 6=flipped-180, 7=flipped-270
  #
  # hyprMonitorsV2 = [
  #   {
  #     output = "DP-1";
  #     mode = "2560x1440@144";
  #     position = "0x0";
  #     scale = 1;
  #     transform = 0;
  #     enabled = true;  # set false to disable this output
  #   }
  #   {
  #     output = "HDMI-A-1";
  #     mode = "1920x1080@60";
  #     position = "2560x0"; # placed to the right
  #     scale = 1.25;
  #     transform = 0;
  #     enabled = true;
  #   }
  #   {
  #     output = "eDP-1";     # laptop panel
  #     mode = "1920x1080@60";
  #     position = "auto";
  #     scale = 1;
  #     transform = 0;
  #     enabled = false;      # explicitly disabled
  #   }
  # ];
}
