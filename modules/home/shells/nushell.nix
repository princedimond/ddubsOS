{pkgs, ...}: {
  programs.nushell = {
    enable = true;
    extraConfig = ''
      # =========================
      # eza aliases (Nushell)
      # =========================
      alias ls = eza
      alias ll = eza -a --no-user --long
      alias la = eza -lah
      alias tree = eza --tree
      alias d = eza -a --grid
      alias dir = eza -a --grid

      # =========================
      # zoxide helpers (Nushell)
      # =========================
      # Interactive selector ("zi"), then cd into selection.
      def --env zi [] {
        let dest = ( ^${pkgs.zoxide}/bin/zoxide query -i )
        if ($dest | is-empty) == false { cd $dest }
      }

      # Basic "z" to jump directly to best match
      def --env z [ ...rest ] {
        let dest = ( ^${pkgs.zoxide}/bin/zoxide query -- $rest | lines | first )
        if ($dest | is-empty) == false { cd $dest }
      }

      # =========================
      # Optional: Starship prompt for Nushell
      # =========================
      # If you want Starship prompt in Nushell, uncomment below and ensure
      # programs.starship is enabled via your selected starshipChoice module.
      # let-env STARSHIP_SHELL = "nushell"
      # let-env PROMPT_COMMAND = ( ^${pkgs.starship}/bin/starship init nu | from nuon )
      # let-env PROMPT_COMMAND_RIGHT = ""
    '';
  };
}
