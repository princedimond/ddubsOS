{ profile, ... }: {
  programs.bash = {
    enable = false;
    enableCompletion = true;
    initExtra = ''
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';
    shellAliases = {
      # Common aliases move to `eza.nix`
      # So all shells get same aliases
      # These need `profile` imported so they stay here
      sv = "sudo nvim";
      fr = "nh os switch --hostname ${profile} && notify-send `ddubsOS` `Rebuild complete`";
      fu = "nh os switch --hostname ${profile} --update && notify-send `ddubsOS` `Upgrade complete`";
      zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/raw/main/install-zaneyos.sh)";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    };
  };
}
