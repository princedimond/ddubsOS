{
  lib,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  enableFAH =
    if builtins.hasAttr "enableFoldingAtHome" vars
    then vars.enableFoldingAtHome
    else false;
  teamId =
    if builtins.hasAttr "foldingTeamId" vars
    then vars.foldingTeamId
    else 1066966; # PewDiePie
in {
  services.foldingathome = lib.mkIf enableFAH {
    enable = true;
    team = teamId;
    # Optional knobs (left default): user, passkey, power, gpu, extraOptions
  };
}
