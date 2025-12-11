{
  pkgs,
  lib,
  ...
}: {
  # Environment hint for helper scripts and bars
  home.sessionVariables = {
    QS_HAS_OXWM = "1";
  };

  # X11 user-space utilities typically needed with a minimal X11 WM
  home.packages = with pkgs; [
    arandr # Set screen resolution
    dunst # notifications
    flameshot # screenshots
    maim # Screenshot util
    nitrogen # wallpapers
    oxwm # from overlays: inputs.oxwm exposed as pkgs.oxwm
    picom # compositor
    polkit_gnome # polkit agent for auth prompts in X11 sessions
    rofi # launcher
    variety # wallpaper manager (optional)
    xclip # clipboard CLI
    xdotool # X11 automation
    xorg.xrandr # display config
    xorg.xrdb # Xresources loader
    xorg.xset # user preferences (DPMS, key repeat)
    xorg.xsetroot # set root window color/name
  ];

  # Optional: start a polkit agent in user session (works under common X11 session targets)
  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "Polkit authentication agent (GNOME)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };

  # Install OxWM config files under ~/.config/oxwm via Home Manager
  xdg.configFile."oxwm/config.lua" = {
    source = ./config.lua;
    # Force replace any pre-existing unmanaged file
    force = true;
  };

  # Provide OxWM Lua API stubs for LSP/autocomplete
  xdg.configFile."oxwm/oxwm.lua" = {
    source = ./oxwm.lua;
    # Force replace any pre-existing unmanaged file
    force = true;
  };
  # Provide OxWM Luaarc.json
  # xdg.configFile."oxwm/.luarc.json" = {
  #   source = ./.luarc.json;
  #   # Force replace any pre-existing unmanaged file
  #   force = true;
  # };
  # Provide OxWM lib dir
  # xdg.configFile."oxwm/lib" = {
  #   source = ./lib;
  #   # Force replace any pre-existing unmanaged file
  #   force = true;
  # };
}
