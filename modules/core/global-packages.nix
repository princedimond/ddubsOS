{
  pkgs,
  stablePkgs,
  inputs,
  ...
}: {
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

    #### Icon themes ####
    papirus-icon-theme
    kdePackages.breeze-icons
    hicolor-icon-theme
    #### END ####

    #### Fish ####
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    grc
    #### END ####

    ###  Testig new tools

    #ali # load generation tool
    asciinema # CLI recording tool
    bandwhich # network bandwidth monitor
    bluetui # CLI BT GUI
    bluetuith # CLI BT GUI
    bmon # monitoring tool
    broot # replacement for tree
    clipse # CLI clipboard mgr
    cointop # bitcoin tracker
    cpufetch # cpu info
    ctop # container top
    countryfetch # info on country
    cyme # list USB devices
    ddgr # duci-duck-go from cli
    delta # diff tool
    diffnav # diff tool
    dino # Jabber xmpp client
    dog #  like cat or bat
    doggo # dns client
    dooit # todo tool
    dooit-extras # todo tool
    dust # du tool
    gajim # Jabber XMPP client
    gcli # git tool
    g-ls # ls replacement
    erdtree # tree
    freetube # youtube client
    frogmouth # Markdown browser for terminal
    fclones # dup finder
    git-cliff # changelog generator
    #gitu # git tool
    #gitui # git tool
    go # Build GO apps
    gtop # system monitor
    gtt # Translate tui
    httm # BTFS timeshift tool
    lsr # ls but readable
    lstr # fast tree lister
    macchina # fetch like tool
    mapscii # world map in term
    mcat # pic viewer in terminal
    mdcat # markdown cat tool
    netscanner # network scan tool  -- fails to build
    netop # network monitor using bpf
    parallel-disk-usage # pdu disk space analyzer
    pkgtop # package tracker / manager
    pik # Interactive process kill tool
    pls # Prettier ls
    procs # Process viewer ps replacement
    snowmachine # make it snow in terminal
    systemctl-tui # systemctl tui
    t-rec # terminal screen recorder
    tailspin # log viewer
    television # fuzzy finder
    trippy # network diag tool
    tuptime # uptime and more
    typespeed # ncurses typing game / trainer
    typioca # typing speed tester
    zf # fuzzy file finder

    astroterm # constellations in terminal
    avidemux # Video editor
    clapgrep # gui / previewer grep/rg tool
    converseen # KDE image tool
    direnv # Used by vscode
    #discord-canary
    discord
    docker-compose # Allows Controlling Docker From A Single File
    fahclient # folding at home client PewDiPie team: 1066966
    figlet # terminal banner maker
    #franz # combined messaging app
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
    #lunarvim # alternative NVIM config
    luarocks # Needed for NeoVIM and LunarVIM
    matugen # color palette generator needed for Hyprpanel
    mission-center # system monitor
    monitorets # floating system monitor
    neohtop # high end perf monitor GUI Doesn't build 9/1/25 mismatched npm/crates
    #neofetch # system info fetcher
    nomacs # video image preview tool
    nerdfetch # fetch using nerd fonts
    netpeek # network scanner
    pastel # CLI color generator / converter
    picard # For Changing Music Metadata & Getting Cover Art
    pinta # simple paint pgm
    proxmox-backup-client # backup home dirs
    remmina # remote connection tool RDP/SSH,etc
    resources # btop like CLI tool
    switcheroo # quick image manipulation tool
    superfile # TUI Filemgr
    typtea # terminal typing test with language support
    twingate # twingate VPN client
    # Geting current warp terminal from flake  9/16/25 Leaving as backup
    #stablePkgs.warp-terminal # AI terminal stable branch running newer versions

    # NUR packages
    #nur.repos.charmbracelet.crush

    upscayl # up scale images
  ];
}
