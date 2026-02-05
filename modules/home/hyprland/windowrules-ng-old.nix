{host, ...}: let
  hostVars = import ../../../hosts/${host}/variables.nix;
  extraMonitorSettings = hostVars.extraMonitorSettings or "";
  hyprMonitorsV2 = hostVars.hyprMonitorsV2 or [];
  monitorLines = builtins.concatStringsSep "\n" (
    map
    (
      m:
        if (m.enabled or true)
        then "monitor = ${m.output},${(m.mode or "preferred")},${(m.position or "auto")},${toString (m.scale or 1)}"
        else "monitor = ${m.output},disable"
    )
    hyprMonitorsV2
  );
in {
  wayland.windowManager.hyprland = {
    # NOTE: This module targets the new Hyprland windowrules rewrite from
    # https://github.com/hyprwm/Hyprland/pull/12269
    # and assumes support for named `windowrule { ... }` blocks.
    #
    # Official syntax and semantics reference:
    #   - Hyprland wiki → Configuring → Window Rules
    #     (see the section describing `windowrule { ... }` and `match:` props)
    #     URL at time of writing:
    #       https://wiki.hypr.land/Configuring/Window-Rules/
    #
    # Rules are injected via extraConfig instead of settings.windowrule/
    # settings.windowrulev2 so we can use the new block syntax directly.
    extraConfig = ''
      ${monitorLines}
      ${extraMonitorSettings}

      # --- Auto-generated window rules (named) ---
      # Source: modules/home/hyprland/windowrules.nix
      # Tool:  ~/Projects/ddubs/hyprrulefix/fix.py --named

      windowrule {
        name = windowrule-1
        match:xwayland = 1
        no_blur = on
      }

      windowrule {
        name = windowrule-2
        match:class = ^(\bresolve\b)$
        match:xwayland = 1
        no_blur = on
      }

      windowrule {
        name = windowrule-3
        match:class = ^(foot-floating)$
        center = on
        float = on
        size = 60% = 60%
      }

      windowrule {
        name = windowrule-4
        match:initial_title = ^(emacs-floating)$
        center = on
        float = on
        size = 70% = 70%
      }

      windowrule {
        name = windowrule-5
        match:title = ^(BoxBuddy)$
        center = on
        float = on
        size = 70% = 70%
      }

      windowrule {
        name = windowrule-6
        match:title = ^(it.mijorus.gearlever)$
        center = on
        float = on
      }

      windowrule {
        name = windowrule-7
        match:class = ^(io.github.kolunmi.Bazaar)$
        center = on
        float = on
        size = 70% = 70%
      }

      windowrule {
        name = windowrule-8
        match:class = mpv
        content = none
      }

      windowrule {
        name = windowrule-9
        match:class = ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$
        tag = +file-manager
      }

      windowrule {
        name = windowrule-10
        match:class = ^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$
        tag = +terminal
      }

      windowrule {
        name = windowrule-11
        match:class = ^(Brave-browser(-beta|-dev|-unstable)?)$
        tag = +browser
      }

      windowrule {
        name = windowrule-12
        match:class = ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$
        tag = +browser
      }

      windowrule {
        name = windowrule-13
        match:class = ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$
        tag = +browser
      }

      windowrule {
        name = windowrule-14
        match:class = ^([Tt]horium-browser|[Cc]achy-browser)$
        tag = +browser
      }

      windowrule {
        name = windowrule-15
        match:class = ^(vlc|mpv)$
        tag = +video
      }

      windowrule {
        name = windowrule-16
        match:class = ^(codium|codium-url-handler|VSCodium)$
        tag = +projects
      }

      windowrule {
        name = windowrule-17
        match:class = ^(VSCode|code-url-handler)$
        tag = +projects
      }

      windowrule {
        name = windowrule-18
        match:class = ^([Dd]iscord|[Dd]iscordcanary|[Ww]ebCord|[Vv]esktop)$
        tag = +im
      }

      windowrule {
        name = windowrule-19
        match:class = ^([Ff]erdium)$
        center = on
        float = on
        size = 60% = 70%
        tag = +im
      }

      windowrule {
        name = windowrule-20
        match:class = ^([Ww]hatsapp-for-linux)$
        tag = +im
      }

      windowrule {
        name = windowrule-21
        match:class = ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$
        tag = +im
      }

      windowrule {
        name = windowrule-22
        match:class = ^(teams-for-linux)$
        tag = +im
      }

      windowrule {
        name = windowrule-23
        match:class = ^(com.obsproject.Studio)$
        tag = +obs
      }

      windowrule {
        name = windowrule-24
        match:class = ^(gamescope)$
        tag = +games
      }

      windowrule {
        name = windowrule-25
        match:class = ^(steam_app\\d+)$
        tag = +games
      }

      windowrule {
        name = windowrule-26
        match:class = ^([Ss]team)$
        tag = +gamestore
      }

      windowrule {
        name = windowrule-27
        match:title = ^([Ll]utris)$
        tag = +gamestore
      }

      windowrule {
        name = windowrule-28
        match:class = ^(com.heroicgameslauncher.hgl)$
        tag = +gamestore
      }

      windowrule {
        name = windowrule-29
        match:class = ^(gnome-disks|wihotspot(-gui)?)$
        tag = +settings
      }

      windowrule {
        name = windowrule-30
        match:class = ^([Rr]ofi)$
        tag = +settings
      }

      windowrule {
        name = windowrule-31
        match:class = ^(file-roller|org.gnome.FileRoller)$
        tag = +settings
      }

      windowrule {
        name = windowrule-32
        match:class = ^(nm-applet|nm-connection-editor|blueman-manager)$
        tag = +settings
      }

      windowrule {
        name = windowrule-33
        match:class = ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$
        center = on
        tag = +settings
      }

      windowrule {
        name = windowrule-34
        match:class = ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$
        tag = +settings
      }

      windowrule {
        name = windowrule-35
        match:class = (xdg-desktop-portal-gtk)
        tag = +settings
      }

      windowrule {
        name = windowrule-36
        match:class = (.blueman-manager-wrapped)
        tag = +settings
      }

      windowrule {
        name = windowrule-37
        match:class = (nwg-displays)
        tag = +settings
      }

      windowrule {
        name = windowrule-38
        match:title = ^(Picture-in-Picture)$
        float = on
        move = 72% = 7%
        opacity = 0.95 = 0.75
        pin = 0
      }

      windowrule {
        name = windowrule-39
        match:class = ([Tt]hunar)
        match:title = negative:(.*[Tt]hunar.*)
        center = on
        float = on
      }

      windowrule {
        name = windowrule-40
        match:title = ^(Authentication Required)$
        center = on
        float = on
      }

      windowrule {
        name = windowrule-41
        match:class = ^(*)$
        idle_inhibit = fullscreen
      }

      windowrule {
        name = windowrule-42
        match:title = ^(*)$
        idle_inhibit = fullscreen
      }

      windowrule {
        name = windowrule-43
        match:fullscreen = 1
        idle_inhibit = fullscreen
      }

      windowrule {
        name = windowrule-44
        match:tag = settings*
        float = on
        opacity = 0.8 = 0.7
        size = 70% = 70%
      }

      windowrule {
        name = windowrule-45
        match:class = ^([Ww]aypaper)$
        float = on
      }

      windowrule {
        name = windowrule-46
        match:class = ^(org.remmina.Remmina)$
        float = on
      }

      windowrule {
        name = windowrule-47
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Wallpapers)$
        border_size = 0
        float = on
        no_blur = on
        rounding = 12
      }

      windowrule {
        name = windowrule-48
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Video Wallpapers)$
        border_size = 0
        center = on
        float = on
        no_blur = on
        rounding = 12
      }

      windowrule {
        name = windowrule-49
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(qs-wlogout)$
        border_size = 0
        center = on
        float = on
        opacity = 1.0 = 1.0
        rounding = 20
      }

      windowrule {
        name = windowrule-50
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Panels)$
        center = on
        float = on
        no_blur = on
        rounding = 12
      }

      windowrule {
        name = windowrule-51
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Hyprland Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-52
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Niri Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-53
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(BSPWM Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-54
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(i3 Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-55
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Sway Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-56
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(DWM Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-57
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Emacs Leader Keybinds)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-58
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Kitty Configuration)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-59
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(WezTerm Configuration)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-60
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Yazi Configuration)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-61
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Cheatsheets Viewer)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-62
        match:class = ^(org\\.qt-project\\.qml)$
        match:title = ^(Documentation Viewer)$
        border_size = 0
        center = on
        float = on
        opacity = 0.95 = 0.95
        rounding = 12
      }

      windowrule {
        name = windowrule-63
        match:class = ^(com.github.rafostar.Clapper)$
        float = on
      }

      windowrule {
        name = windowrule-64
        match:class = ^(io.github.zingytomato.netpeek)$
        center = on
        float = on
      }

      windowrule {
        name = windowrule-65
        match:class = (codium|codium-url-handler|VSCodium)
        match:title = negative:(.*codium.*|.*VSCodium.*)
        float = on
      }

      windowrule {
        name = windowrule-66
        match:class = ^(com.heroicgameslauncher.hgl)$
        match:title = negative:(Heroic Games Launcher)
        float = on
      }

      windowrule {
        name = windowrule-67
        match:class = ^([Ss]team)$
        match:title = negative:^([Ss]team)$
        float = on
      }

      windowrule {
        name = windowrule-68
        match:initial_title = (Add Folder to Workspace)
        float = on
        size = 70% = 60%
      }

      windowrule {
        name = windowrule-69
        match:initial_title = (Open Files)
        float = on
        size = 70% = 60%
      }

      windowrule {
        name = windowrule-70
        match:initial_title = (wants to save)
        float = on
      }

      windowrule {
        name = windowrule-71
        match:tag = browser*
        opacity = 1.0 = 1.0
        workspace = 2
      }

      windowrule {
        name = windowrule-72
        match:tag = video*
        opacity = 1.0 = 1.0
      }

      windowrule {
        name = windowrule-73
        match:tag = projects*
        opacity = 0.9 = 0.8
      }

      windowrule {
        name = windowrule-74
        match:tag = im*
        opacity = 0.94 = 0.86
        workspace = 3
      }

      windowrule {
        name = windowrule-75
        match:tag = file-manager*
        opacity = 0.9 = 0.8
      }

      windowrule {
        name = windowrule-76
        match:tag = terminal*
        opacity = 1.0 = 0.8
      }

      windowrule {
        name = windowrule-77
        match:class = ^(gedit|org.gnome.TextEditor|mousepad)$
        opacity = 0.8 = 0.7
      }

      windowrule {
        name = windowrule-78
        match:class = ^(seahorse)$ # gnome-keyring gui
        opacity = 0.9 = 0.8
      }

      windowrule {
        name = windowrule-79
        match:tag = games*
        no_blur = on
      }

      windowrule {
        name = windowrule-80
        match:class = org.remmina.Reminna
        workspace = 8
      }

      windowrule {
        name = windowrule-81
        match:tag = obs*
        workspace = 10
      }

      # --- Auto-generated layer rules ---
    '';
  };
}
