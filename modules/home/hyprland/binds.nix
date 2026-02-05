{
  host,
  pkgs,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  inherit
    (vars)
    browser
    terminal
    panelChoice
    ;

  hyprLayoutInit = pkgs.writeShellScriptBin "hypr-layout-init" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Determine current layout; retry briefly to avoid early-startup nulls
    attempts=0
    LAYOUT=""
    while [ $attempts -lt 3 ] && [ -z "${LAYOUT:-}" ]; do
      LAYOUT=$(hyprctl -j getoption general:layout | ${pkgs.jq}/bin/jq -r '.str // empty' 2>/dev/null || true)
      if [ -z "${LAYOUT:-}" ]; then
        # Fallback: parse non-JSON output (e.g., "str: dwindle")
        LAYOUT=$(hyprctl getoption general:layout 2>/dev/null | awk -F'str:' 'NF>1 {gsub(/^ +| +$/,"",$2); print $2}')
      fi
      [ -n "${LAYOUT:-}" ] && break
      attempts=$((attempts+1))
      sleep 0.25
    done
    [ -z "${LAYOUT:-}" ] && exit 0

    case "$LAYOUT" in
      master)
        # Ensure master layout-style binds
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
        hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
        ;;
      dwindle)
        # Ensure dwindle layout-style binds
        hyprctl keyword unbind SUPER,J
        hyprctl keyword unbind SUPER,K
        hyprctl keyword unbind SUPER,O
        hyprctl keyword bind SUPER,J,cyclenext
        hyprctl keyword bind SUPER,K,cyclenext,prev
        # ensure SUPER+O togglesplit is available on dwindle
        hyprctl keyword bind SUPER,O,togglesplit
        ;;
    esac
  '';

  swapLayout = pkgs.writeShellScriptBin "hypr-swap-layout" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Read current layout with a short retry loop (early startup can return empty)
    attempts=0
    LAYOUT=""
    while [ $attempts -lt 3 ] && [ -z "${LAYOUT:-}" ]; do
      LAYOUT=$(hyprctl -j getoption general:layout | ${pkgs.jq}/bin/jq -r '.str // empty' 2>/dev/null || true)
      if [ -z "${LAYOUT:-}" ]; then
        LAYOUT=$(hyprctl getoption general:layout 2>/dev/null | awk -F'str:' 'NF>1 {gsub(/^ +| +$/,"",$2); print $2}')
      fi
      [ -n "${LAYOUT:-}" ] && break
      attempts=$((attempts+1))
      sleep 0.25
    done
    case "$LAYOUT" in
      master)
        hyprctl keyword general:layout dwindle ;;
      dwindle)
        hyprctl keyword general:layout master ;;
    esac
    # Reinitialize J/K binds for the new layout
    hypr-layout-init
  '';
in {
  home.packages = [hyprLayoutInit swapLayout];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Initialize SUPER+J/K binds to match the current layout at login
      "hypr-layout-init"
    ];

    bindd = [
      # ============= APPLICATION LAUNCHERS & MENUS =============
      "SUPER CTRL,D, Toggle Dock, exec, dock" # Application dock toggle
      "SUPER, TAB, QS Overview, exec, qs ipc -c overview call overview toggle"
      "SUPER SHIFT,R, Rofi Legacy Menu, exec, rofi-legacy.menu"
      "SUPER,R, Rofi Menu, exec, rofi.menu"

      # ============= noctalia-shell binds (enabled when panelChoice = "noctalia") =============
      "SUPER, D, noctalia Main Menu, exec, noctalia-shell  ipc call launcher toggle   # Main enu"
      "SUPER, M, noctalia Notifcaitons, exec, noctalia-shell ipc call notifications toggleHistory  # Notifcaitons "
      "SUPER, V, noctalia clipboard, exec,  noctalia-shell ipc call launcher clipboard # clipboard"
      "SUPER ALT, P, noctalia Settings,  exec, noctalia-shell ipc call settings toggle   # settings "
      "SUPER SHIFT, comma, noctalia Settings,  exec, noctalia-shell ipc call settings toggle   # settings "
      "SUPER ALT , L, noctalia Lock screen, exec, noctalia-shell ipc call sessionMenu lockAndSuspend   #  lock screen"
      "SUPER SHIFT , Y , noctalia Wallpaper, exec, noctalia-shell ipc call wallpaper toggle   # Pick Wallpaper   "
      "SUPER , X , noctalia Powermenu, exec, noctalia-shell ipc call sessionMenu toggle   # Logout menu  "
      "SUPER , C , noctalia Control Center, exec, noctalia-shell ipc call controlCenter toggle   # Control center "
      "SUPER CTRL , R , noctalia screen record , exec, noctalia-shell ipc call screenRecorder toggle   # Screen Record toggle "
      "SUPER ALT , R , Restart Noctalia-shell , exec, restart.noctalia    # Restart Noctalia-shell "

      # ============= dms-shell binds (enabled when panelChoice = "dms") =============
      "SUPER, D, DMS Main Menu, exec, dms ipc call spotlight toggle # Main enu"
      "SUPER, M, DMS Notifcaitons, exec, dms ipc call notifications open # Notifcaitons "
      "SUPER, V, DMS clipboard, exec, dms ipc call clipboard toggle  # clipboard"
      "SUPER ALT, P, Process List,  exec, dms ipc call processlist open   # Process list "
      "SUPER SHIFT, comma, DMS Settings,  exec,  dms ipc call settings toggle  # settings "
      "SUPER ALT , L, DMS Idle ihhibit toggle, exec, dms ipc call inhibit toggle   #  Idle ihibit toggle"
      "SUPER SHIFT , Y , DMS Wallpaper, exec, dms ipc call dankdash wallpaper  # Pick Wallpaper   "
      "SUPER , X , DMS Powermenu, exec, dms ipc call powermenu toggle   # Logout menu  "
      "SUPER , C , DMS control Center, exec, dms ipc call control-center toggle   # Control center "
      "SUPER, O , DMS overview , exec, dms ipc call hypr toggleOverview   # Workspace overview "
      "SUPER CTRL, R , DMS screenshot region , exec, dms    # screenshot region "

      # ============= TERMINALS =============
      "SUPER,Return, Terminal, exec, ${terminal}"
      "SUPER SHIFT,Return, Foot Terminal (Floating), exec, foot --app-id=foot-floating"
      "SUPER ALT,Return, WezTerm, exec, wezterm"
      "SUPER CTRL,Return, Ghostty, exec, ghostty"
      "SUPER CTRL ALT,Return, Kitty BG (Random Wallpaper), exec, kitty-bg"
      "SUPER CTRL ALT,G, Ghostty BG (Random Wallpaper), exec, ghostty-bg"
      "SUPER SHIFT,T, DropDown Terminal, exec, sh -lc 'DropTerminal ''${TERM:-kitty}'"

      # ============= TEXT EDITORS & IDEs =============
      "ALT,E, Emacs Floating, exec, emacsclient -c -a '' --frame-parameters='((name . \"emacs-floating\") (explicit-name . t))'"
      "SUPER ,E, Emacs, exec, emacsclient -c"
      "SUPER,G, VS Code, exec, vscode"

      # ============= WEB & COMMUNICATION =============
      "SUPER,W, Web Browser, exec, ${browser}"
      "SUPER ALT,D, Discord Canary, exec, discordcanary"

      # ============= FILE MANAGEMENT =============
      "SUPER,T, Thunar, exec, thunar"
      "SUPER,Y, Yazi, exec, kitty -e yazi"

      # ============= SYSTEM UTILITIES =============
      "SUPER SHIFT,V, Clipboard History, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
      "SUPER SHIFT,N, Create Note From Clipboard, exec, note-from-clipboard"
      "SUPER ALT,C, Color Picker, exec, hyprpicker -a"
      "SUPER CTRL,S, Screenshot, exec, screenshootin"
      "SUPER SHIFT,S, Screenshot Satty, exec, screenshootin-satty"
      "ALT SHIFT,S, Screenshot Region, exec, hyprshot -m region -o $HOME/Pictures/Screenshots"
      "SUPER,O, OBS Studio, exec, obs"
      "SUPER ALT,M, Audio Control, exec, pavucontrol"
      "SUPER SHIFT,E, Emoji Picker, exec, emopicker9000"

      # ============= SYSTEM SETTINGS & CONFIGURATION =============
      "SUPER ALT,S, Settings Dialog, exec, hyprpanel toggleWindow settings-dialog"
      "SUPER SHIFT,N, Notifications Reset, exec, swaync-client -rs"
      "SUPER SHIFT,P, Power Menu, exec, $HOME/.config/waybar/scripts/power-menu.sh"
      "SUPER SHIFT,W, Apply Wallpapers, exec, qs-wallpapers-apply"
      "SUPER ALT,W, Warp Build, exec, warp-bld"
      "SUPER,I, Toggle Screenlock, exec, toggle-idle"
      "ALT SHIFT,Q, Logout Menu, exec, qs-wlogout"

      # ============= DOCUMENTATION & HELP =============
      "SUPER SHIFT,K, Keybinds Help, exec, WARP_PANEL_CHOICE=${panelChoice} qs-keybinds"
      "SUPER SHIFT,C, Cheatsheets, exec, qs-cheatsheets"
      "SUPER SHIFT,D, Docs, exec, qs-docs"

      # ============= WINDOW MANAGEMENT =============
      "SUPER SHIFT,G, Smart Gaps Toggle, exec, smart-gaps"
      "SUPER,Q, Kill Active Window, killactive,"
      "SUPER ALT,F, Toggle Fullscreen, fullscreen,"
      "SUPER,F, Maximize (keep bars), fullscreen, 1"
      "SUPER SHIFT,F, Toggle Floating, togglefloating,"
      "SUPER,SPACE, Toggle Floating, togglefloating"
      "SUPER SHIFT,SPACE, Workspace All Float, workspaceopt, allfloat"
      "SUPER,P, Pseudo Tile, pseudo,"
      "SUPER SHIFT, M, Swap Layout, exec, hypr-swap-layout"
      "SUPER SHIFT,I, Toggle Split, togglesplit,"

      # ============= WINDOW MOVEMENT (ARROW KEYS) =============
      "SUPER SHIFT,left, Move Window Left, movewindow, l"
      "SUPER SHIFT,right, Move Window Right, movewindow, r"
      "SUPER SHIFT,up, Move Window Up, movewindow, u"
      "SUPER SHIFT,down, Move Window Down, movewindow, d"

      # ============= WINDOW MOVEMENT (VI-STYLE HJKL) =============
      "SUPER SHIFT,h, Move Window Left, movewindow, l"
      "SUPER SHIFT,l, Move Window Right, movewindow, r"
      "SUPER SHIFT,k, Move Window Up, movewindow, u"
      "SUPER SHIFT,j, Move Window Down, movewindow, d"

      # ============= WINDOW SWAPPING (ARROW KEYS) =============
      "SUPER ALT, left, Swap Window Left, swapwindow, l"
      "SUPER ALT, right, Swap Window Right, swapwindow, r"
      "SUPER ALT, up, Swap Window Up, swapwindow, u"
      "SUPER ALT, down, Swap Window Down, swapwindow, d"

      # ============= WINDOW SWAPPING (VI-STYLE KEYCODES) =============

      # ============= FOCUS MOVEMENT (ARROW KEYS) =============
      "SUPER,left, Focus Left, movefocus, l"
      "SUPER,right, Focus Right, movefocus, r"
      "SUPER,up, Focus Up, movefocus, u"
      "SUPER,down, Focus Down, movefocus, d"

      # ============= FOCUS MOVEMENT (VI-STYLE HJKL) =============
      "SUPER,h, Focus Left, movefocus, l"
      "SUPER,l, Focus Right, movefocus, r"
      "SUPER ALT,k, Focus Up (vi-alt), movefocus, u"
      "SUPER ALT,j, Focus Down (vi-alt), movefocus, d"

      # ============= WINDOW CYCLING =============
      "ALT,Tab, Cycle Next Window, cyclenext"
      "ALT,Tab, Bring Active To Top, bringactivetotop"

      # SUPER+J/K — dynamic cycle binds (default to dwindle; runtime script adjusts at login and after swaps)

      # ============= WORKSPACE SWITCHING (1-10) =============
      "SUPER,1, Workspace 1, workspace, 1"
      "SUPER,2, Workspace 2, workspace, 2"
      "SUPER,3, Workspace 3, workspace, 3"
      "SUPER,4, Workspace 4, workspace, 4"
      "SUPER,5, Workspace 5, workspace, 5"
      "SUPER,6, Workspace 6, workspace, 6"
      "SUPER,7, Workspace 7, workspace, 7"
      "SUPER,8, Workspace 8, workspace, 8"
      "SUPER,9, Workspace 9, workspace, 9"
      "SUPER,0, Workspace 10, workspace, 10"

      # ============= MOVE WINDOW TO WORKSPACE (1-10) =============
      "SUPER SHIFT,1, Move To Workspace 1, movetoworkspace, 1"
      "SUPER SHIFT,2, Move To Workspace 2, movetoworkspace, 2"
      "SUPER SHIFT,3, Move To Workspace 3, movetoworkspace, 3"
      "SUPER SHIFT,4, Move To Workspace 4, movetoworkspace, 4"
      "SUPER SHIFT,5, Move To Workspace 5, movetoworkspace, 5"
      "SUPER SHIFT,6, Move To Workspace 6, movetoworkspace, 6"
      "SUPER SHIFT,7, Move To Workspace 7, movetoworkspace, 7"
      "SUPER SHIFT,8, Move To Workspace 8, movetoworkspace, 8"
      "SUPER SHIFT,9, Move To Workspace 9, movetoworkspace, 9"
      "SUPER SHIFT,0, Move To Workspace 10, movetoworkspace, 10"

      # ============= WORKSPACE NAVIGATION =============
      "SUPER CONTROL,right, Next Workspace, workspace, e+1"
      "SUPER CONTROL,left, Previous Workspace, workspace, e-1"
      "SUPER,mouse_down, Next Workspace Mouse, workspace, e+1"
      "SUPER,mouse_up, Previous Workspace Mouse, workspace, e-1"

      # ============= MEDIA & HARDWARE CONTROLS =============
      ",XF86AudioRaiseVolume, Volume Up, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, Volume Down, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      " ,XF86AudioMute, Mute Toggle, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioPlay, Play Pause, exec, playerctl play-pause"
      ",XF86AudioPause, Play Pause, exec, playerctl play-pause"
      ",XF86AudioNext, Next Track, exec, playerctl next"
      ",XF86AudioPrev, Previous Track, exec, playerctl previous"
      ",XF86MonBrightnessDown, Brightness Down, exec, brightnessctl set 5%-"
      ",XF86MonBrightnessUp, Brightness Up, exec, brightnessctl set +5%"
    ];
    # bind = [
    # ============= DISABLED/COMMENTED BINDINGS =============
    # "SUPER SHIFT,W,exec,web-search"                     # Web search (disabled)
    # "SUPER SHIFT,W,exec, rofi-wallpapers-apply"         # Replaced by qs-wallpapers-apply
    # "SUPER CTRL,W,exec,waypaper"                        # Replaced by qs-wallpapers-apply
    # "SUPER SHIFT,SPACE,movetoworkspace,special"         # Special workspace (commented)
    # "SUPER,SPACE,togglespecialworkspace"                # Toggle special workspace (commented)
    #"SUPER SHIFT,Q,exit,"                                # Exit Hyprland (disabled - too easy to hit)
    #"SUPER SHIFT,D,exec, rofi-legacy.menu"               # Replaced by other launcher
    #"SUPER SHIFT,K,exec, list-keybinds"                  # Replaced by qs-keybinds
    #"SUPER,A, AGS Overview, exec, agsv1 -t 'overview'"
    # "SUPER ALT,T, Pyprland Scratchpad, exec, pypr toggle term"

    # ============= DISABLED Menus =============
    #"SUPER ALT,R,exec, bemenu-run -c -l 10 -W 0.2 -H 20 --fixed-height --fn 'JetBrains Mono 19' -p :" # Bemenu launcher
    #"SUPER ALT,P,exec, nwg-drawer -mb 100 -mt 100 -mr 300 -ml 300" # NWG drawer launcher
    #  "SUPER,S, Window List, exec, rofi -show window"
    #  "SUPER,P, Panel Switcher , exec, rofi-panels"
    #];
    #
    bindmd = [
      "SUPER, mouse:272, Move Window (Mouse), movewindow"
      "SUPER, mouse:273, Resize Window (Mouse), resizewindow"
    ];
  };
}
