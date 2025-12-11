{
  pkgs,
  config,
  lib,
  ...
}: let
  enableNwgApps = true; # Set to true to enable the configuration
  styleCss = ''
    window {
      background: rgba(0, 0, 0, 0.8);
      border-radius: 10px;
      border-style: solid;
      border-width: 3px;
      border-color: #ffffff;
      opacity: 0.8;
    }

    #box {
      /* Define attributes of the box surrounding icons here */
      padding: 10px;
    }

    #active {
      /* This is to underline the button representing the currently active window */
      border-bottom: solid 0px;
      border-color: #ffffff;
    }

    button,
    image {
      background: none;
      border-style: none;
      box-shadow: none;
      color: #999;
    }

    button {
      padding: 4px;
      margin-left: 4px;
      margin-right: 4px;
      color: #eee;
      font-size: 12px;
    }

    button:hover {
      background-color: rgba(255, 255, 255, 0.15);
      border-radius: 10px;
    }

    button:focus {
      box-shadow: none;
    }
  '';
  menuTxt = ''
    nwg-menu -isl 32 -iss 18 -k -ml 10 -mt 0 -va top -s "$HOME/.config/nwg-menu/style.css" -cmd-lock string  "hyprlock" -cmd-logout "hyprctl dispatch exit"
  '';
in {
  home.packages = with pkgs; (
    if enableNwgApps
    then [
      # Python update causing build failures 8/25/25
      nwg-menu
      nwg-bar
      nwg-dock-hyprland
      nwg-launchers
      nwg-clipman
      nwg-panel
      nwg-drawer
      nwg-displays
    ]
    else []
  );

  # Place nwg-menu configuration files under XDG config directory
  xdg.configFile = lib.mkIf enableNwgApps {
    "nwg-menu/style.css".text = styleCss;
    "nwg-menu/nwg-menu.txt".text = menuTxt;
  };
}
