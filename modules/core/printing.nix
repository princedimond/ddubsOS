{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) printEnable;
in
{
  services = {
    printing = {
      enable = true;
      drivers = [
        # pkgs.hplipWithPlugin
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
  };
}
