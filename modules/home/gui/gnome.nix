{ pkgs, ... }: {
  # Enable plugins at build time
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "burn-my-windows@schneegans.github.com"
        "caffeine@patapon.info"
        "appindicatorsupport@rgcjonas.gmail.com"
        "simple-workspaces-bar@fthx"
        "desktop-cube@schneegans.github.com"
        "clipboard-indicator@tudmotu.com"
        "Vitals@CoreCoding.com"
        "wiggle@mechtifs"
        #  Some other common extensions
        #       "forge@jmmaranan.com"
        #       "ddterm@amezin.github.com"
        #       "paperwm@hedning:matrix.org"
        #       "just-perfection-desktop@just-perfection"
        #       "open-bar@neuromorph"
        #"workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        #       "yakuake@krisives.github.com"
        #       "pop-shell@system76.com"
        #       "system-monitor@paradoxxx.zero.gmail.com"
      ];
    };
  };

  home.packages = with pkgs; [
    ### GNOME ####
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.pop-shell
    gnomeExtensions.caffeine
    gnomeExtensions.yakuake
    gnomeExtensions.appindicator
    gnomeExtensions.simple-workspaces-bar
    gnomeExtensions.desktop-cube
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.vitals
    gnomeExtensions.forge
    gnomeExtensions.wiggle
    gnomeExtensions.ddterm
    gnomeExtensions.paperwm
    gnomeExtensions.just-perfection
    gnomeExtensions.open-bar
    gnomeExtensions.workspace-indicator
    gnomeExtensions.system-monitor
    gnome-extension-manager
    gnome-tweaks

    # GNOME applications previously in global system packages
    gnome-boxes # GUI for QEMU
    gnome-frog # select screen area extract text
    ####  END  ####
  ];
}
