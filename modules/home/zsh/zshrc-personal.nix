{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    zoxide
  ];

  home.file."./.zshrc-personal".text = ''

    #!/usr/bin/env zsh

    # Set defaults
    #
    export EDITOR="nvim"
    export VISUAL="nvim"
    # 
    # Source Gemini API key if available
    if [ -f "$HOME/gem.key" ]; then
      source "$HOME/gem.key"
    fi


    # Goes up a specified number of directories  (i.e. up 4)
    up() {
      local d=""
      limit=$1
      for ((i = 1; i <= limit; i++)); do
        d=$d/..
      done
      d=$(echo $d | sed 's/^\///')
      if [ -z "$d" ]; then
        d=..
      fi
      cd $d
    }

    #  My aliases.  common aliases move to `eza.nix`
    #
    alias psmem='ps auxf | sort -nr -k 4'
    alias psmem10='ps auxf | sort -nr -k 4 | head -10'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias grep='ugrep --color=auto'
    alias fgrep='ugrep -F --color=auto'
    #alias dm="$HOME/.emacs.d/bin/doom run"
    alias dm="emacs -nw"

    # Adding path for DOOM emacs
    export PATH="$HOME/.local/bin/:$HOME/.emacs.d/bin:$PATH"

    #eval "$(oh-my-posh init zsh --config $HOME/.config/powerlevel10k_rainbow.omp.json)"
    # Persistence now set globally
    #eval "$(ssh-agent -s)" &>/dev/null
    #ssh-add ~/.ssh/id_ed25519
    # Run minimal fetch
    nitch

  '';
}
