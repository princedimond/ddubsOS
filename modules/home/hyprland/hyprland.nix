{
  host,
  config,
  pkgs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    keyboardLayout
    ;
in
{
  home.packages = with pkgs; [
    swww
    grim
    grimblast
    slurp
    wl-clipboard
    wf-recorder
    wl-screenrec
    wlr-randr
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils # needed for banners and ANR
    hyprland-qt-support
    hyprland-protocols
    hyprpicker
    hyprpaper
    hyprshot
    hyprls
    #uwsm #universal wayland session mgr
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./ddubsos-mtn-purple-small.jpg;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    xwayland = {
      enable = true;
    };
    settings = {
      input = {
        kb_layout = "${keyboardLayout}";
        kb_options = [
          "grp:alt_caps_toggle"
          "caps:super"
        ];
        numlock_by_default = false;
        repeat_delay = 300;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          scroll_factor = 0.8;
        };
      };

      general = {
        "$modifier" = "SUPER";
        layout = "dwindle";
        gaps_in = 6;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
        "col.active_border" =
          "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      dwindle = {
        pseudotile = true;
        # smart_split will split where your mouse is
        smart_split = false;
        #always split to right or bottom
        force_split = 2;
        preserve_split = true;
      };

      master = {
        new_status = "master";
        new_on_top = 1;
        mfact = 0.5;
      };

      ####### Disable nagware ####

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
        enforce_permissions = false; # require elevated access
      };

      # Ensure Xwayland windows render at integer scale; compositor scales them
      xwayland = {
        force_zero_scaling = true;
      };
    };

    extraConfig = "
      ${extraMonitorSettings}
    ";
  };
}
