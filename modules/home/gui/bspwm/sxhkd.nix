{
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + b" = "google-chrome-stable";
      "super + shift + b" = "google-chrome-stable --incognito";
      "super + Return" = "kitty";
      "super + space" = "rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons";
      "super + d" = "rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons";
      "super + shift + Return" = "wezterm";
      "super + h" = "kitty -e ~/.config/bspwm/keyhelper.sh";
      "super + f" = "thunar";
      "super + e" = "kitty -e nvim";
      "super + c" = "discord-canary";
      "super + v" = "kitty -e pulsemixer";
      "super + shift + d" = "discord";
      "super + o" = "obs";
      "super + shift + {t,s,f}" = "bspc node -t {tiled,floating,fullscreen}";
      "super + Escape" = "pkill -USR1 -x sxhkd; notify-send 'sxhkd' 'Reloaded config'";
      "super + shift + r" = "bspc wm -r; notify-send 'bspwm' 'Restarted'";
      "super + shift + q" = "bspc quit";
      "super + q" = "bspc node -c";
      "super + i" = "bspc node -R 90";
      "super + shift + i" = "bspc node -R -90";
      "super + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
      "super + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";
      "super + {_,shift + }{1-9,0}" = "bspc {desktop --focus,node --to-desktop} 'focused:^{1-9,10}' --follow";
      "super + ctrl + {Left,Down,Up,Right}" = "{bspc node -z left -40 0; bspc node -z right -40 0, bspc node -z bottom 0 40; bspc node -z top 0 40, bspc node -z bottom 0 -40; bspc node -z top 0 -40, bspc node -z left 40 0; bspc node -z right 40 0}";
      "super + shift + delete" = "~/scripts/changevolume up";
      "super + Delete" = "~/scripts/changevolume down";
      "super + m" = "~/scripts/changevolume mute";
      "{XF86AudioRaiseVolume,XF86AudioLowerVolume}" = "pamixer {-i,-d} 2";
      "{XF86MonBrightnessUp,XF86MonBrightnessDown}" = "xbacklight {+10,-10}";
      "super + s" = "scrot -s -e 'mv $f ~/Screenshots'; notify-send 'Scrot' 'Selected image to ~/Screenshots'";
      "super + shift + s" = "scrot -e 'mv $f ~/Screenshots'; notify-send 'Scrot' 'Image saved to ~/Screenshots'";
      "super + alt + r" = "~/scripts/redshift-on";
      "super + alt + b" = "~/scripts/redshift-off";
      "super + @equal" = "bspc query -N -d | xargs -I % bspc node % -B";
    };
  };
}
