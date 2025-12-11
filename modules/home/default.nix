{
  host,
  inputs,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit
    (vars)
    panelChoice
    waybarChoice
    starshipChoice
    gnomeEnable
    bspwmEnable
    i3Enable
    dwmEnable
    wayfireEnable
    cosmicEnable
    enableEvilhelix
    enableVscode
    enableAntiGravity
    enableMicro
    enableAlacritty
    enableTmux
    enablePtyxis
    enableWezterm
    enableRio
    enableTwin
    enableOpencode
    enableDevEnv
    enableObs
    enableIncus
    enableZed
    enableZenBrowser
    enableLadybird
    enableVicinae
    vicinaeProfile
    niriEnable
    enableNixvim
    enableSway
    enableMangowc
    oxwmEnable
    ;
  shellChoice = vars.shellChoice or "zsh";

  # Conditional shell imports driven by host variable `shellChoice`
  shellImports =
    if shellChoice == "zsh"
    then [
      ./zsh/default.nix
      ./zsh/zshrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ]
    else if shellChoice == "bash"
    then [
      ./shells/bash.nix
      ./shells/bashrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ]
    else if shellChoice == "fish"
    then [
      ./shells/fish.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ]
    else if shellChoice == "nushell"
    then [
      ./shells/nushell.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ]
    else [
      # Fallback to zsh if invalid value provided
      ./zsh/default.nix
      ./zsh/zshrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ];
in {
  imports =
    [
      ./amfora.nix
      ./gtk.nix
      ./qt.nix
      ./scripts
      ./stylix.nix
      ./xdg/default-apps.nix

      #Hyprland
      ./wlogout
      ./hyprland
      ./hyprpanel.nix

      # GUI Apps
      ./gui-apps/default.nix
      ./gui/bemenu.nix
      ./gui/wofi.nix

      #CLI Utils
      ./cli/default.nix
      starshipChoice
      ./gh.nix
      ./yazi

      # noctalia
      ./gui/noctalia.nix

      # Storage automounts (udiskie)
      ./udiskie.nix

      # Terminals
      ./terminals/default.nix
      ./terminals/zellij.nix

      # Editors (selected per host)
      ./editors/doom-emacs.nix
      ./editors/nano.nix
    ]
    ++ shellImports
    ++ (
      if enableNixvim
      then [./editors/nixvim.nix]
      else [./nvf.nix]
    )
    ++ (
      if panelChoice == "noctalia"
      then [./gui/noctalia.nix]
      else []
    )
    ++ [waybarChoice]
    ++ (
      if (vars ? enableMangowc) && enableMangowc
      then [inputs.mangowc.hmModules.mango ./gui/mangowc/mangowc.nix]
      else []
    )
    ++ (
      if gnomeEnable
      then [./gui/gnome.nix]
      else []
    )
    ++ (
      if enableZed
      then [./editors/zed-editor.nix]
      else []
    )
    ++ (
      if bspwmEnable
      then [./gui/bspwm.nix]
      else []
    )
    ++ (
      if i3Enable
      then [./gui/i3.nix]
      else []
    )
    ++ (
      if (vars ? oxwmEnable) && oxwmEnable
      then [./gui/oxwm/oxwm.nix]
      else []
    )
    ++ (
      if dwmEnable
      then [./suckless/default.nix]
      else []
    )
    ++ (
      if enableSway
      then [./gui/sway.nix]
      else []
    )
    ++ (
      if wayfireEnable
      then [./gui/wayfire.nix]
      else []
    )
    ++ (
      if cosmicEnable
      then [./gui/cosmic-de.nix]
      else []
    )
    ++ (
      if enableEvilhelix
      then [./editors/evil-helix.nix]
      else []
    )
    ++ (
      if enableVscode
      then [./editors/vscode.nix]
      else []
    )
    ++ (
      if enableAntiGravity
      then [./gui-apps/google-antigravity.nix]
      else []
    )
    ++ (
      if enableMicro
      then [./editors/micro.nix]
      else []
    )
    ++ (
      if enableAlacritty
      then [./terminals/alacritty.nix]
      else []
    )
    ++ (
      if enableTmux
      then [./terminals/tmux.nix]
      else []
    )
    ++ (
      if enablePtyxis
      then [./terminals/ptyxis.nix]
      else []
    )
    ++ (
      if enableWezterm
      then [./terminals/wezterm.nix]
      else []
    )
    ++ (
      if (vars ? enableRio) && enableRio
      then [./terminals/rio.nix]
      else []
    )
    ++ (
      if enableTwin
      then [./terminals/twin.nix]
      else []
    )
    ++ (
      if enableObs
      then [./gui-apps/obs-studio.nix]
      else []
    )
    ++ (
      if (vars ? enableIncus) && enableIncus
      then [./gui-apps/incus.nix]
      else []
    )
    ++ (
      if enableOpencode
      then [./cli/opencode.nix]
      else []
    )
    ++ (
      if enableDevEnv
      then [./dev-env.nix]
      else []
    )
    ++ (
      if enableZenBrowser
      then [./gui-apps/zen-browser.nix]
      else []
    )
    ++ (
      if enableLadybird
      then [./gui-apps/ladybird.nix]
      else []
    )
    ++ (
      if enableVicinae
      then [./vicinae.nix]
      else []
    )
    ++ (
      if niriEnable
      then [./gui/niri/niri.nix]
      else []
    );
}
