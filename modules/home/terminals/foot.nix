{ lib, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "JetBrains Mono:size=12";
        shell = "zsh"; # Uses the SHELL environment variable, fallback to /etc/passwd
        term = "foot"; # Falls back to "xterm-256color" if built with -Dterminfo=disabled
        login-shell = "no"; # Prevents Foot from launching as a login shell
      };
      cursor = {
        style = "beam";
        blink = "yes";
        beam-thickness = 1.5;
        underline-thickness = 1.0;
      };
      colors = {
        background = "1e1e2e";
        foreground = "cdd6f4";
        cursor = "111111 dcdccc";
        selection-background = "44475a";
        selection-foreground = "ffffff";
      };
      scrollback = {
        lines = 5000;
      };
      bell = {
        urgent = "no";
        notify = "no";
      };
    };
  };
}
