{ host, ... }:
let
  hostVars = import ../../../hosts/${host}/variables.nix;
  extraMonitorSettings = hostVars.extraMonitorSettings or "";
  hyprMonitorsV2 = hostVars.hyprMonitorsV2 or [ ];
  monitorLines = builtins.concatStringsSep "\n" (
    map (
      m:
      if (m.enabled or true) then
        "monitor = ${m.output},${(m.mode or "preferred")},${(m.position or "auto")},${toString (m.scale or 1)}"
      else
        "monitor = ${m.output},disable"
    ) hyprMonitorsV2
  );
in
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        #"noblur, xwayland:1" # Helps prevent odd borders/shadows for xwayland apps
        # downside it can impact other xwayland apps
        # This rule is a template for a more targeted approach
        "noblur, class:^(\bresolve\b)$, xwayland:1" # Window rule for just resolve
        "float, class:^(foot-floating)$"
        "size 60% 60%, class:^(foot-floating)$"
        "center, class:^(foot-floating)$"
        "float, initialTitle:^(emacs-floating)$"
        "size 70% 70%, initialTitle:^(emacs-floating)$"
        "center, initialTitle:^(emacs-floating)$"
        "content none, class:mpv" # prevents black screen whem maximizing
        "content none, class:mpv" # prevents black screen whem maximizing
        "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tag +terminal, class:^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"
        "tag +browser, class:^(Brave-browser(-beta|-dev|-unstable)?)$"
        "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
        "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
        "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"
        "tag +video, class:^(vlc|mpv)$"
        "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, class:^(VSCode|code-url-handler)$"
        "tag +im, class:^([Dd]iscord|[Dd]iscordcanary|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, class:^([Ff]erdium)$"
        "tag +im, class:^([Ww]hatsapp-for-linux)$"
        "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +im, class:^(teams-for-linux)$"
        "tag +obs, class:^(com.obsproject.Studio)$"
        "tag +games, class:^(gamescope)$"
        "tag +games, class:^(steam_app_\d+)$"
        "tag +gamestore, class:^([Ss]team)$"
        "tag +gamestore, title:^([Ll]utris)$"
        "tag +gamestore, class:^(com.heroicgameslauncher.hgl)$"
        "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, class:^([Rr]ofi)$"
        "tag +settings, class:^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "tag +settings, class:^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, class:(xdg-desktop-portal-gtk)"
        "tag +settings, class:(.blueman-manager-wrapped)"
        "tag +settings, class:(nwg-displays)"
        "move 72% 7%,title:^(Picture-in-Picture)$"
        "center, class:^([Ff]erdium)$"
        "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
        "center, title:^(Authentication Required)$"
        "idleinhibit fullscreen, class:^(*)$"
        "idleinhibit fullscreen, title:^(*)$"
        "idleinhibit fullscreen, fullscreen:1"
        "float, tag:settings*"
        "float, class:^([Ff]erdium)$"
        "float, class:^([Ww]aypaper)$"
        "float, class:^(org.remmina.Remmina)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Wallpapers)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Video Wallpapers)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Video Wallpapers)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(qs-wlogout)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(qs-wlogout)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Hyprland Keybinds)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Niri Keybinds)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(BSPWM Keybinds)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(DWM Keybinds)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Emacs Leader Keybinds)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Kitty Configuration)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(WezTerm Configuration)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Yazi Configuration)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Cheatsheets Viewer)$"
        "float, class:^(org\\.qt-project\\.qml)$, title:^(Documentation Viewer)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Hyprland Keybinds)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Niri Keybinds)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(BSPWM Keybinds)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(DWM Keybinds)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Emacs Leader Keybinds)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Kitty Configuration)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(WezTerm Configuration)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Yazi Configuration)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Cheatsheets Viewer)$"
        "center, class:^(org\\.qt-project\\.qml)$, title:^(Documentation Viewer)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(com.github.rafostar.Clapper)$"
        "float, title:^(Authentication Required)$"
        "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
        "float, class:^(com.heroicgameslauncher.hgl)$, title:negative:(Heroic Games Launcher)"
        "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
        "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
        "float, initialTitle:(Add Folder to Workspace)"
        "float, initialTitle:(Open Files)"
        "float, initialTitle:(wants to save)"
        "size 70% 60%, initialTitle:(Open Files)"
        "size 70% 60%, initialTitle:(Add Folder to Workspace)"
        "size 70% 70%, tag:settings*"
        "size 60% 70%, class:^([Ff]erdium)$"
        "opacity 1.0 1.0, tag:browser*"
        "opacity 1.0 1.0, tag:video*"
        "opacity 0.9 0.8, tag:projects*"
        "opacity 0.94 0.86, tag:im*"
        "opacity 0.9 0.8, tag:file-manager*"
        "opacity 1.0 0.8, tag:terminal*"
        "opacity 0.8 0.7, tag:settings*"
        "opacity 0.8 0.7, class:^(gedit|org.gnome.TextEditor|mousepad)$"
        "opacity 0.9 0.8, class:^(seahorse)$ # gnome-keyring gui"
        "opacity 0.95 0.75, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "keepaspectratio, title:^(Picture-in-Picture)$"
        "noblur, tag:games*"
        "workspace 3, tag:im*"
        "workspace 2, tag:browser*"
        "workspace 8, class:org.remmina.Reminna"
        "workspace 10, tag:obs*"
      ];

      # Per-window v2 rules for additional styling
      windowrulev2 = [
        # Rofi (rofi-wayland) app id is typically "rofi"
        "rounding 18, class:^(rofi)$"
        "opacity 0.96 0.96, class:^(rofi)$"

        # qs-wallpapers picker styling via compositor
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Wallpapers)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Wallpapers)$"
        "noblur, class:^(org\\.qt-project\\.qml)$, title:^(Wallpapers)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Wallpapers)$"

        # qs-vid-wallpapers styling via compositor
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Video Wallpapers)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Video Wallpapers)$"
        "noblur, class:^(org\\.qt-project\\.qml)$, title:^(Video Wallpapers)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Video Wallpapers)$"

        # qs-wlogout styling via compositor - power menu overlay
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(qs-wlogout)$"
        "rounding 20, class:^(org\\.qt-project\\.qml)$, title:^(qs-wlogout)$"
        "opacity 1.0 1.0, class:^(org\\.qt-project\\.qml)$, title:^(qs-wlogout)$"

        # qs-keybinds styling via compositor - keybinds menu overlay
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Hyprland Keybinds)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Niri Keybinds)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(BSPWM Keybinds)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(DWM Keybinds)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Emacs Leader Keybinds)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Kitty Configuration)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(WezTerm Configuration)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Yazi Configuration)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Cheatsheets Viewer)$"
        "noborder, class:^(org\\.qt-project\\.qml)$, title:^(Documentation Viewer)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Hyprland Keybinds)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Niri Keybinds)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Emacs Leader Keybinds)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Kitty Configuration)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(WezTerm Configuration)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Yazi Configuration)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Cheatsheets Viewer)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(Documentation Viewer)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(BSPWM Keybinds)$"
        "noshadow, class:^(org\\.qt-project\\.qml)$, title:^(DWM Keybinds)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Hyprland Keybinds)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Niri Keybinds)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(BSPWM Keybinds)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(DWM Keybinds)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Emacs Leader Keybinds)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Kitty Configuration)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(WezTerm Configuration)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Yazi Configuration)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Cheatsheets Viewer)$"
        "rounding 12, class:^(org\\.qt-project\\.qml)$, title:^(Documentation Viewer)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Hyprland Keybinds)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Niri Keybinds)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(BSPWM Keybinds)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(DWM Keybinds)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Emacs Leader Keybinds)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Kitty Configuration)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(WezTerm Configuration)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Yazi Configuration)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Cheatsheets Viewer)$"
        "opacity 0.95 0.95, class:^(org\\.qt-project\\.qml)$, title:^(Documentation Viewer)$"

        # Bright blue border for fullscreen windows
        "bordercolor rgb(0080FF), fullscreen:1"
      ];

    };

    extraConfig = ''
      ${monitorLines}
      ${extraMonitorSettings}
    '';
  };
}
