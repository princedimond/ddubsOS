{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      hackgen-nf-font
      iosevka
      ibm-plex
      icomoon-feather
      inter
      jetbrains-mono
      lilex
      material-icons
      material-symbols
      maple-mono.NF
      meslo-lg
      minecraftia
      noto-fonts
      nerd-fonts.blex-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.code-new-roman
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.dejavu-sans-mono
      noto-fonts-color-emoji
      nerd-fonts.fira-mono
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.im-writing
      nerd-fonts.iosevka
      nerd-fonts.lilex
      nerd-fonts.meslo-lg
      noto-fonts-monochrome-emoji
      nerd-fonts.space-mono
      nerd-fonts.ubuntu
      powerline-fonts
      roboto
      roboto-mono
      symbola # Fails to DL (again) 11/20/25
      terminus_font
    ];
  };
}
