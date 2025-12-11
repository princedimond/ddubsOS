{
  pkgs,
  inputs,
  ...
}: {
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
    };
  };
}
