{ host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in
{
  wayland.windowManager.hyprland.settings = {
    bindd = [
      # ============= APPLICATION LAUNCHERS & MENUS =============
      "$modifier CTRL,D, Toggle Dock, exec, dock" # Application dock toggle
      "ALT, space, Workspace Overview, exec, vicinae"
      "$modifier,A, App Overview, exec, agsv1 -t 'overview'"
      "$modifier,R, Rofi Legacy Menu, exec, rofi-legacy.menu"
      "$modifier,D, Rofi Menu, exec, rofi.menu"

      # ============= TERMINALS =============
      "$modifier,Return, Terminal, exec, ${terminal}"
      "$modifier SHIFT,Return, Foot Terminal (Floating), exec, foot --app-id=foot-floating"
      "$modifier ALT,Return, WezTerm, exec, wezterm"
      "$modifier CTRL,Return, Ghostty, exec, ghostty"
      "$modifier SHIFT,T, Scratchpad Terminal, exec, pypr toggle term"

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
      "$modifier,V, Clipboard History, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
      "$modifier,N, Create Note From Clipboard, exec, note-from-clipboard"
      "$modifier,C, Color Picker, exec, hyprpicker -a"
      "$modifier,S, Screenshot, exec, screenshootin"
      "$modifier SHIFT,S, Screenshot Satty, exec, screenshootin-satty"
      "ALT SHIFT,S, Screenshot Region, exec, hyprshot -m region -o $HOME/Pictures/Screenshots"
      "$modifier,O, OBS Studio, exec, obs"
      "$modifier,M, Audio Control, exec, pavucontrol"
      "$modifier SHIFT,E, Emoji Picker, exec, emopicker9000"

      # ============= SYSTEM SETTINGS & CONFIGURATION =============
      "$modifier ALT,S, Settings Dialog, exec, hyprpanel toggleWindow settings-dialog"
      "$modifier SHIFT,N, Notifications Reset, exec, swaync-client -rs"
      "$modifier SHIFT,P, Power Menu, exec, $HOME/.config/waybar/scripts/power-menu.sh"
      "$modifier SHIFT,W, Apply Wallpapers, exec, qs-wallpapers-apply"
      "$modifier ALT,W, Warp Build, exec, warp-bld"
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
      "$modifier SHIFT, M, Swap Layout, exec, swap_layout"
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
      "$modifier ALT, 43, Swap Window Left, swapwindow, l"
      "$modifier ALT, 46, Swap Window Right, swapwindow, r"
      "$modifier ALT, 45, Swap Window Up, swapwindow, u"
      "$modifier ALT, 44, Swap Window Down, swapwindow, d"

      # ============= FOCUS MOVEMENT (ARROW KEYS) =============
      "$modifier,left, Focus Left, movefocus, l"
      "$modifier,right, Focus Right, movefocus, r"
      "$modifier,up, Focus Up, movefocus, u"
      "$modifier,down, Focus Down, movefocus, d"

      # ============= FOCUS MOVEMENT (VI-STYLE HJKL) =============
      "$modifier,h, Focus Left, movefocus, l"
      "$modifier,l, Focus Right, movefocus, r"
      "$modifier,k, Focus Up, movefocus, u"
      "$modifier,j, Focus Down, movefocus, d"

      # ============= WINDOW CYCLING =============
      "ALT,Tab, Cycle Next Window, cyclenext"
      "ALT,Tab, Bring Active To Top, bringactivetotop"

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

    # ============= DISABLED PLUGINS =============
    # hyprspace plugin  Disabled 9/13/25  Won't build
    #"$modifier, TAB, overview:toggle, all"
    #"$modifier SHIFT, TAB, overview:close, all"
    # hyprexpo plugin
    #"ALT, space, hyprexpo:expo, toggle"

    # ============= DISABLED/COMMENTED BINDINGS =============
    # "$modifier SHIFT,W,exec,web-search"                     # Web search (disabled)
    # "$modifier SHIFT,W,exec, rofi-wallpapers-apply"         # Replaced by qs-wallpapers-apply
    # Disabled wallsetter I don't like auto change wallpapers
    #"$modifier ALT,W,exec,wallsetter"
    # "$modifier CTRL,W,exec,waypaper"                        # Replaced by qs-wallpapers-apply
    # "$modifier SHIFT,SPACE,movetoworkspace,special"         # Special workspace (commented)
    # "$modifier,SPACE,togglespecialworkspace"                # Toggle special workspace (commented)
    #"$modifier SHIFT,Q,exit,"                                # Exit Hyprland (disabled - too easy to hit)
    #"$modifier SHIFT,D,exec, rofi-legacy.menu"               # Replaced by other launcher
    #"$modifier SHIFT,K,exec, list-keybinds"                  # Replaced by qs-keybinds

    # ============= DISABLED Menus =============
    #"$modifier SHIFT,R,exec, wofi --show drun"               # Wofi application launcher
    #"$modifier ALT,R,exec, bemenu-run -c -l 10 -W 0.2 -H 20 --fixed-height --fn 'JetBrains Mono 19' -p :" # Bemenu launcher
    #"$modifier ALT,P,exec, nwg-drawer -mb 100 -mt 100 -mr 300 -ml 300" # NWG drawer launcher
    #];
    #
    bindmd = [
      "$modifier, mouse:272, Move Window (Mouse), movewindow"
      "$modifier, mouse:273, Resize Window (Mouse), resizewindow"
    ];
    #bindm = [
    #];
  };
}
