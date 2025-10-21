{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix)
    waybarChoice
    starshipChoice
    gnomeEnable
    bspwmEnable
    dwmEnable
    wayfireEnable
    cosmicEnable
    enableEvilhelix
    enableVscode
    enableMicro
    enableAlacritty
    enableTmux
    enablePtyxis
    enableWezterm
    enableTwin
    enableOpencode
    enableDevEnv
    enableObs
    enableZed
    enableZenBrowser
    enableVicinae
    vicinaeProfile
    niriEnable
    ;
in
{
  imports = [
    ./amfora.nix
    ./gtk.nix
    ./qt.nix
    ./scripts
    ./stylix.nix
    ./xdg/default-apps.nix

    #Hyprland
    waybarChoice
    ./wlogout
    ./hyprland
    ./hyprpanel.nix

    # GUI Apps
    ./gui-apps/default.nix
    ./gui/bemenu.nix
    ./gui/wofi.nix

    # Shells
    ./shells/bash.nix
    ./shells/bashrc-personal.nix
    ./shells/eza.nix
    ./shells/fish.nix
    ./shells/zoxide.nix
    ./zsh/default.nix
    ./zsh/zshrc-personal.nix

    #CLI Utils
    ./cli/default.nix
    starshipChoice
    ./gh.nix
    ./yazi

    # Storage automounts (udiskie)
    ./udiskie.nix

    # Termiknals
    ./terminals/default.nix

    # Editors
    ./nvf.nix # NVIM configuration
    ./editors/doom-emacs.nix
    ./editors/nano.nix
  ]
  ++ (if gnomeEnable then [ ./gui/gnome.nix ] else [ ])
  ++ (if enableZed then [ ./editors/zed-editor.nix ] else [ ])
  ++ (if bspwmEnable then [ ./gui/bspwm.nix ] else [ ])
  ++ (if dwmEnable then [ ./suckless/default.nix ] else [ ])
  ++ (if wayfireEnable then [ ./gui/wayfire.nix ] else [ ])
  ++ (if cosmicEnable then [ ./gui/cosmic-de.nix ] else [ ])
  ++ (if enableEvilhelix then [ ./editors/evil-helix.nix ] else [ ])
  ++ (if enableVscode then [ ./editors/vscode.nix ] else [ ])
  ++ (if enableMicro then [ ./editors/micro.nix ] else [ ])
  ++ (if enableAlacritty then [ ./terminals/alacritty.nix ] else [ ])
  ++ (if enableTmux then [ ./terminals/tmux.nix ] else [ ])
  ++ (if enablePtyxis then [ ./terminals/ptyxis.nix ] else [ ])
  ++ (if enableWezterm then [ ./terminals/wezterm.nix ] else [ ])
  ++ (if enableTwin then [ ./terminals/twin.nix ] else [ ])
  ++ (if enableObs then [ ./gui-apps/obs-studio.nix ] else [ ])
  ++ (if enableOpencode then [ ./cli/opencode.nix ] else [ ])
  ++ (if enableDevEnv then [ ./dev-env.nix ] else [ ])
  ++ (if enableZenBrowser then [ ./gui-apps/zen-browser.nix ] else [ ])
  ++ (if enableVicinae then [ ./vicinae.nix ] else [ ])
  ++ (if niriEnable then [ ./gui/niri/niri.nix ] else [ ]);
}
