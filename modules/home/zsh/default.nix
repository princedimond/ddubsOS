{profile, ...}: {
  imports = [
    #./zshrc-personal.nix
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "root"
        "line"
      ];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
    };

    #    plugins = [
    #  {
    #  name = "powerlevel10k";
    #src = pkgs.zsh-powerlevel10k;
    #file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    #  }
    #  {
    #name = "powerlevel10k-config";
    #src = lib.cleanSource ./p10k-config;
    #file = "p10k.zsh";
    #  }
    #];

    initContent = ''
       # Set default terminal for applications
      export TERMINAL="kitty"
      export XDG_TERMINAL_EMULATOR="kitty"
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word
      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi
    '';

    shellAliases = {
      # Common aliases moved to `exa.nix`
      # So all shells get same aliases
      # These are here for now since they need the `profile` imported
      fr = "nh os switch --hostname ${profile}";
      rebuild = "nh os switch --hostname ${profile}";
      fu = "nh os switch --hostname ${profile}";
      update = "nh os switch --hostname ${profile} --update";
      #zu = "sh <(curl -L https://gitlab.com/dwilliam62/zaneyos-current/-/blob/ffc41c3ccdb4efdb23b88e98839f554ebdcc4c3f/install-ddubsos.sh.broken)";
    };
  };
}
