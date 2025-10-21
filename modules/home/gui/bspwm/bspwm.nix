{ pkgs
, lib
, ...
}: {
  xsession.windowManager.bspwm = {
    enable = lib.mkForce true;
    settings = {
      border_width = lib.mkForce 4;
      window_gap = lib.mkForce 10;
      split_ratio = lib.mkForce 0.5;
      single_monocle = lib.mkForce false;
      focus_follows_pointer = lib.mkForce true;
      borderless_monocle = lib.mkForce true;
      gapless_monocle = lib.mkForce true;
      presel_feedback_color = lib.mkForce "#1a1a1a";
      active_border_color = lib.mkForce "#4fc3f7";
      focused_border_color = lib.mkForce "#4fc3f7";
      normal_border_color = lib.mkForce "#1a1a1a";
    };
    rules = lib.mkForce {
      "*" = {
        rectangle = "1280x720+0+0";
        center = true;
      };
      "qimgv" = { state = "floating"; };
      "sxiv" = { state = "floating"; };
      "Xarchiver" = {
        state = "floating";
        layer = "normal";
      };
      "mpv" = {
        state = "floating";
        layer = "normal";
      };
      "Pavucontrol:pavucontrol" = { state = "floating"; };
      "Lxappearance" = {
        state = "floating";
        layer = "normal";
      };
      "wezterm" = {
        state = "floating";
        layer = "normal";
        sticky = true;
      };
      "ghosty" = {
        state = "floating";
        layer = "normal";
        sticky = true;
      };
      "discord" = {
        desktop = "^3";
        follow = true;
      };
    };
    monitors = lib.mkForce {
      "Virtual-1" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ];
    };
    extraConfig = ''
      xrandr --output Virtual-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal
      polkit-gnome-authentication-agent-1 &
      dunst &
      pkill variety
      sleep 0.5
      variety &
      pkill volumeicon
      sleep 0.3
      volumeicon &
      pkill flameshot
      sleep 0.3
      flameshot &
      #tranmission-qt &
      clipmenu &
    '';
  };
}
