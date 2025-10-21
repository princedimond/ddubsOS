{
  pkgs,
  ...
}:
{
  gtk = {
    iconTheme = {
      name = "candy-icons";
      package = pkgs.candy-icons;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
