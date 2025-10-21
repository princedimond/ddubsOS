{ pkgs, stablePkgs, ... }:
{
  programs = {
    wayfire = {
      enable = true;
      plugins = with pkgs.wayfirePlugins; [
        wcm # Wayfire Configuration Manager
        wf-shell # Shell/panel
        wayfire-plugins-extra # Additional plugins
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    ###  Global Apps ###

    #### Fish ####
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    grc
    #### END ####

    # Installing for RBM
    affine
    astroterm # constellations in terminal
    avidemux # Video editor
    #clapgrep # gui / previewer grep/rg tool
    converseen # KDE image tool
    direnv # Used by vscode
    discord-canary
    discord
    docker-compose # Allows Controlling Docker From A Single File
    figlet # terminal banner maker
    ferdium # combined messaging app
    fortune # daily fortune needed by variety
    gitnuro # desktop gui for git
    glab # gitlab cli toosl
    grim # needed for screenshots
    grimblast # needed for screenshots
    gpu-screen-recorder # good cli screen recorder
    gpu-viewer # front end for glxinfo
    hyfetch # includisve system fetch
    iotop # IO monitoring tool
    kdePackages.okular # PDF reader
    losslesscut-bin # Cut videos w/o re-rendering
    lnav # Log navigator  great tool to review logs
    lunarvim # alternative NVIM config
    luarocks # Needed for NeoVIM and LunarVIM
    matugen # color palette generator needed for Hyprpanel
    microsoft-edge # microsoft's chromium based web browser
    mission-center # system monitor
    monitorets # floating system monitor
    #neohtop # high end perf monitor GUI Doesn't build 9/1/25 mismatched npm/crates
    neofetch # system info fetcher
    nomacs # video image preview tool
    netpeek # network scanner
    pastel # CLI color generator / converter
    picard # For Changing Music Metadata & Getting Cover Art
    pinta # simple paint pgm
    remmina # remote connection tool RDP/SSH,etc
    resources # btop like CLI tool
    switcheroo # quick image manipulation tool
    superfile # TUI Filemgr
    typtea # terminal typing test with language support
    twingate # twingate VPN client
    # Geting current warp terminal from flake  9/16/25 Leaving as backup
    #warp-terminal # AI integrated terminal unstable branch
    # stablePkgs.warp-terminal # AI terminal stable branch running newer versions

    # NUR packages
    nur.repos.charmbracelet.crush

    upscayl # up scale images
  ];
}
