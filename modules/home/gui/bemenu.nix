{ lib, pkgs, ... }:

{
  programs.bemenu = {
    enable = true;
    package = pkgs.bemenu;
    settings = lib.mkForce {
      line-height = 20;
      prompt = ":";
      ignorecase = true;
      fn = "JetBrains Mono 19";
      tf = "#B052B9";
      hf = "#B052B9";
      nb = "#000000";
      tb = "#000000";
      fb = "#000000";
      hb = "#000000";
      ab = "#000000";

      # Geometry / placement
      width-factor = 0.2;  # same as -W 0.2
      list = 10;           # same as -l 10 (vertical)
      center = true;       # same as -c (Wayland/X11)
      no-overlap = false;  # avoid forcing top position; center works reliably
    };
  };
}
