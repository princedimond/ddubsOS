{ host, lib, ... }:
let
  hostVars = import ../../hosts/${host}/variables.nix;
  dmChoice = hostVars.dmChoice or "SDDM"; # allowed values: "SDDM" | "TUI"
  useLy = dmChoice == "TUI";
in
{
  config = lib.mkIf useLy {
    # Prefer ly when TUI is selected; avoid greetd conflicts
    services.greetd.enable = lib.mkDefault false;

    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
      };
    };
  };
}