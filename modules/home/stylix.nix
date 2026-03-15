_: {
  stylix.enableReleaseChecks = false;
  stylix.targets = {
    alacritty.enable = false;
    btop.enable = false;
    foot.enable = false;
    fish.enable = false;
    ghostty.enable = false;
    gtk.enable = true; #setting 4now b/c false breaks themeing
    hyprland.enable = false;
    hyprlock.enable = false;
    kitty.enable = false;
    neovim.enable = false;
    nvf.enable = false;
    nixvim.enable = false;
    gtksourceview.enable = false;
    qt = {
      enable = true;
      platform = "qtct";
    };
    rofi.enable = false;
    tmux.enable = false;
    waybar.enable = false;
    wezterm.enable = false;
    vscode.enable = false;
    yazi.enable = false;
  };
}
