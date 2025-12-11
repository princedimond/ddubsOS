{
  lib,
  pkgs,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  i3Enable =
    if builtins.hasAttr "i3Enable" vars
    then vars.i3Enable
    else false;
in
  lib.mkIf i3Enable {
    # Enable i3 window manager via xserver module
    # This automatically provides the i3 session to display managers
    services.xserver.windowManager.i3.enable = true;
  }
