{ pkgs, ... }:
{
  home.packages = [ pkgs.micro ];

  # Andromeda theme for micro
  home.file.".config/micro/colorschemes/andromeda.micro".text = ''
    color-link default "#cdd3de"
    color-link comment "#747c8a"
    color-link constant "#c792ea"
    color-link constant.string "#c3e88d"
    color-link constant.number "#f78c6c"
    color-link type "#ffcb6b"
    color-link identifier "#82aaff"
    color-link statement "#89ddff"
    color-link preproc "#89ddff"
    color-link special "#f07178"
    color-link error "bold #ff5370"
    color-link todo "bold #ffcb6b"
    color-link statusline "#1e2127,#cdd3de"
    color-link tabbar "#1e2127,#747c8a"
    color-link activetab "#1e2127,#cdd3de"
    color-link gutter-error "#ff5370"
    color-link gutter-warning "#ffcb6b"
    color-link diff-added "#c3e88d"
    color-link diff-modified "#82aaff"
    color-link diff-deleted "#ff5370"
    color-link cursor-line "#2a2d35"
    color-link selection "bold #4f5b66"
    color-link symbol "#f07178"
    color-link line-number "#747c8a"
    color-link current-line-number "#cdd3de"
    color-link indent-char "#4f5b66"
    color-link background "#22252b"
  '';

  # Visual, usability, and per-language options
  home.file.".config/micro/settings.json".text = builtins.toJSON {
    colorscheme = "andromeda";
    number = true;
    cursorline = true;
    hlsearch = true;
    incsearch = true;
    matchbrace = true;
    scrollbar = true;
    colorcolumn = 100;

    softwrap = true;
    tabsize = 4;
    tabstospaces = true;
    autoindent = true;
    rmtrailingws = true;
    savecursor = true;

    ftoptions = {
      json = {
        tabsize = 2;
        tabstospaces = true;
      };
      yaml = {
        tabsize = 2;
        tabstospaces = true;
      };
      html = {
        tabsize = 2;
        tabstospaces = true;
      };
      css = {
        tabsize = 2;
        tabstospaces = true;
      };
      javascript = {
        tabsize = 2;
        tabstospaces = true;
      };
      nix = {
        tabsize = 2;
        tabstospaces = true;
      };
      c = {
        tabsize = 4;
        tabstospaces = true;
      };
      sh = {
        tabsize = 2;
        tabstospaces = true;
      };
    };
  };
}
