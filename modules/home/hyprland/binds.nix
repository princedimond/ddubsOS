{
  host,
  pkgs,
  ...
}: let
  inherit
    (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
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
      "$modifier CTRL,D, Toggle Dock, exec, dock" # Application dock toggle
      "$modifier, TAB, QS Overview, exec, qs ipc -c overview call overview toggle"
      "$modifier,A, AGS Overview, exec, agsv1 -t 'overview'"
      "$modifier SHIFT,R, Rofi Legacy Menu, exec, rofi-legacy.menu"
      "$modifier,R, Rofi Menu, exec, rofi.menu"
      "$modifier,S, Window List, exec, rofi -show window"
      "$modifier,P, Panel Switcher , exec, rofi-panels"

      # ============= noctalia-shell binds =============

      "$modifier, D, noctalia Main Menu, exec, noctalia-shell  ipc call launcher toggle   # Main enu"
      "$modifier, M, noctalia Notifcaitons, exec, noctalia-shell ipc call notifications toggleHistory  # Notifcaitons "
      "$modifier, V, noctalia clipboard, exec,  noctalia-shell ipc call launcher clipboard # clipboard"
      "$modifier ALT, P, noctalia Settings,  exec, noctalia-shell ipc call settings toggle   # settings "
      "$modifier SHIFT, comma, noctalia Settings,  exec, noctalia-shell ipc call settings toggle   # settings "
      "$modifier ALT , L, noctalia Lock screen, exec, noctalia-shell ipc call sessionMenu lockAndSuspend   #  lock screen"
      "$modifier SHIFT , Y , noctalia Wallpaper, exec, noctalia-shell ipc call wallpaper toggle   # Pick Wallpaper   "
      "$modifier , X , noctalia Powermenu, exec, dms noctalia-shell call sessionMenu toggle   # Logout menu  "
      "$modifier , C , noctalia Control Center, exec, noctalia-shell ipc call controlCenter toggle   # Control center "
      "$modifier CTRL , R , noctalia screen record , exec, noctalia-shell ipc call screenRecorder toggle   # Screen Record toggle "

      # ============= TERMINALS =============
      "$modifier,Return, Terminal, exec, ${terminal}"
      "$modifier SHIFT,Return, Foot Terminal (Floating), exec, foot --app-id=foot-floating"
      "$modifier ALT,Return, WezTerm, exec, wezterm"
      "$modifier CTRL,Return, Ghostty, exec, ghostty"
      "$modifier CTRL ALT,Return, Kitty BG (Random Wallpaper), exec, kitty-bg"
      "$modifier CTRL ALT,G, Ghostty BG (Random Wallpaper), exec, ghostty-bg"
      "$modifier SHIFT,T, DropDown Terminal, exec, sh -lc 'DropTerminal ''${TERM:-kitty}'"
      "$modifier ALT,T, Pyprland Scratchpad, exec, pypr toggle term"

      # ============= TEXT EDITORS & IDEs =============
      "ALT,E, Emacs Floating, exec, emacsclient -c -a '' --frame-parameters='((name . \"emacs-floating\") (explicit-name . t))'"
      "$modifier ,E, Emacs, exec, emacsclient -c"
      "$modifier,G, VS Code, exec, vscode"

      # ============= WEB & COMMUNICATION =============
      "$modifier,W, Web Browser, exec, ${browser}"
      "$modifier ALT,D, Discord Canary, exec, discordcanary"

      # ============= FILE MANAGEMENT =============
      "$modifier,T, Thunar, exec, thunar"
      "$modifier,Y, Yazi, exec, kitty -e yazi"

      # ============= SYSTEM UTILITIES =============
      "$modifier SHIFT,V, Clipboard History, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
      "$modifier SHIFT,N, Create Note From Clipboard, exec, note-from-clipboard"
      "$modifier ALT,C, Color Picker, exec, hyprpicker -a"
      "$modifier CTRL,S, Screenshot, exec, screenshootin"
      "$modifier SHIFT,S, Screenshot Satty, exec, screenshootin-satty"
      "ALT SHIFT,S, Screenshot Region, exec, hyprshot -m region -o $HOME/Pictures/Screenshots"
      "$modifier,O, OBS Studio, exec, obs"
      "$modifier ALT,M, Audio Control, exec, pavucontrol"
      "$modifier SHIFT,E, Emoji Picker, exec, emopicker9000"

      # ============= SYSTEM SETTINGS & CONFIGURATION =============
      "$modifier ALT,S, Settings Dialog, exec, hyprpanel toggleWindow settings-dialog"
      "$modifier SHIFT,N, Notifications Reset, exec, swaync-client -rs"
      "$modifier SHIFT,P, Power Menu, exec, $HOME/.config/waybar/scripts/power-menu.sh"
      "$modifier SHIFT,W, Apply Wallpapers, exec, qs-wallpapers-apply"
      "$modifier ALT,W, Warp Build, exec, warp-bld"
      "$modifier,I, Toggle Screenlock, exec, toggle-idle"
      "ALT SHIFT,Q, Logout Menu, exec, qs-wlogout"

      # ============= DOCUMENTATION & HELP =============
      "$modifier SHIFT,K, Keybinds Help, exec, qs-keybinds"
      "$modifier SHIFT,C, Cheatsheets, exec, qs-cheatsheets"
      "$modifier SHIFT,D, Docs, exec, qs-docs"

      # ============= WINDOW MANAGEMENT =============
      "$modifier SHIFT,G, Smart Gaps Toggle, exec, smart-gaps"
      "$modifier,Q, Kill Active Window, killactive,"
      "$modifier ALT,F, Toggle Fullscreen, fullscreen,"
      "$modifier,F, Maximize (keep bars), fullscreen, 1"
      "$modifier SHIFT,F, Toggle Floating, togglefloating,"
      "$modifier,SPACE, Toggle Floating, togglefloating"
      "$modifier SHIFT,SPACE, Workspace All Float, workspaceopt, allfloat"
      "$modifier,P, Pseudo Tile, pseudo,"
      "$modifier SHIFT, M, Swap Layout, exec, hypr-swap-layout"
      "$modifier SHIFT,I, Toggle Split, togglesplit,"

      # ============= WINDOW MOVEMENT (ARROW KEYS) =============
      "$modifier SHIFT,left, Move Window Left, movewindow, l"
      "$modifier SHIFT,right, Move Window Right, movewindow, r"
      "$modifier SHIFT,up, Move Window Up, movewindow, u"
      "$modifier SHIFT,down, Move Window Down, movewindow, d"

      # ============= WINDOW MOVEMENT (VI-STYLE HJKL) =============
      "$modifier SHIFT,h, Move Window Left, movewindow, l"
      "$modifier SHIFT,l, Move Window Right, movewindow, r"
      "$modifier SHIFT,k, Move Window Up, movewindow, u"
      "$modifier SHIFT,j, Move Window Down, movewindow, d"

      # ============= WINDOW SWAPPING (ARROW KEYS) =============
      "$modifier ALT, left, Swap Window Left, swapwindow, l"
      "$modifier ALT, right, Swap Window Right, swapwindow, r"
      "$modifier ALT, up, Swap Window Up, swapwindow, u"
      "$modifier ALT, down, Swap Window Down, swapwindow, d"

      # ============= WINDOW SWAPPING (VI-STYLE KEYCODES) =============

      # ============= FOCUS MOVEMENT (ARROW KEYS) =============
      "$modifier,left, Focus Left, movefocus, l"
      "$modifier,right, Focus Right, movefocus, r"
      "$modifier,up, Focus Up, movefocus, u"
      "$modifier,down, Focus Down, movefocus, d"

      # ============= FOCUS MOVEMENT (VI-STYLE HJKL) =============
      "$modifier,h, Focus Left, movefocus, l"
      "$modifier,l, Focus Right, movefocus, r"
      "$modifier ALT,k, Focus Up (vi-alt), movefocus, u"
      "$modifier ALT,j, Focus Down (vi-alt), movefocus, d"

      # ============= WINDOW CYCLING =============
      "ALT,Tab, Cycle Next Window, cyclenext"
      "ALT,Tab, Bring Active To Top, bringactivetotop"

      # SUPER+J/K — dynamic cycle binds (default to dwindle; runtime script adjusts at login and after swaps)

      # ============= WORKSPACE SWITCHING (1-10) =============
      "$modifier,1, Workspace 1, workspace, 1"
      "$modifier,2, Workspace 2, workspace, 2"
      "$modifier,3, Workspace 3, workspace, 3"
      "$modifier,4, Workspace 4, workspace, 4"
      "$modifier,5, Workspace 5, workspace, 5"
      "$modifier,6, Workspace 6, workspace, 6"
      "$modifier,7, Workspace 7, workspace, 7"
      "$modifier,8, Workspace 8, workspace, 8"
      "$modifier,9, Workspace 9, workspace, 9"
      "$modifier,0, Workspace 10, workspace, 10"

      # ============= MOVE WINDOW TO WORKSPACE (1-10) =============
      "$modifier SHIFT,1, Move To Workspace 1, movetoworkspace, 1"
      "$modifier SHIFT,2, Move To Workspace 2, movetoworkspace, 2"
      "$modifier SHIFT,3, Move To Workspace 3, movetoworkspace, 3"
      "$modifier SHIFT,4, Move To Workspace 4, movetoworkspace, 4"
      "$modifier SHIFT,5, Move To Workspace 5, movetoworkspace, 5"
      "$modifier SHIFT,6, Move To Workspace 6, movetoworkspace, 6"
      "$modifier SHIFT,7, Move To Workspace 7, movetoworkspace, 7"
      "$modifier SHIFT,8, Move To Workspace 8, movetoworkspace, 8"
      "$modifier SHIFT,9, Move To Workspace 9, movetoworkspace, 9"
      "$modifier SHIFT,0, Move To Workspace 10, movetoworkspace, 10"

      # ============= WORKSPACE NAVIGATION =============
      "$modifier CONTROL,right, Next Workspace, workspace, e+1"
      "$modifier CONTROL,left, Previous Workspace, workspace, e-1"
      "$modifier,mouse_down, Next Workspace Mouse, workspace, e+1"
      "$modifier,mouse_up, Previous Workspace Mouse, workspace, e-1"

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
    # "$modifier SHIFT,W,exec,web-search"                     # Web search (disabled)
    # "$modifier SHIFT,W,exec, rofi-wallpapers-apply"         # Replaced by qs-wallpapers-apply
    # "$modifier CTRL,W,exec,waypaper"                        # Replaced by qs-wallpapers-apply
    # "$modifier SHIFT,SPACE,movetoworkspace,special"         # Special workspace (commented)
    # "$modifier,SPACE,togglespecialworkspace"                # Toggle special workspace (commented)
    #"$modifier SHIFT,Q,exit,"                                # Exit Hyprland (disabled - too easy to hit)
    #"$modifier SHIFT,D,exec, rofi-legacy.menu"               # Replaced by other launcher
    #"$modifier SHIFT,K,exec, list-keybinds"                  # Replaced by qs-keybinds

    # ============= DISABLED Menus =============
    #"$modifier ALT,R,exec, bemenu-run -c -l 10 -W 0.2 -H 20 --fixed-height --fn 'JetBrains Mono 19' -p :" # Bemenu launcher
    #"$modifier ALT,P,exec, nwg-drawer -mb 100 -mt 100 -mr 300 -ml 300" # NWG drawer launcher
    #];
    #
    bindmd = [
      "$modifier, mouse:272, Move Window (Mouse), movewindow"
      "$modifier, mouse:273, Resize Window (Mouse), resizewindow"
    ];
  };
}
