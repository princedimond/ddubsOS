{ pkgs
, inputs
, username
, host
, profile
, hmUseGlobalPkgs ? false
, ...
}:
let
  vars = import ../../hosts/${host}/variables.nix;
  gitUsername = vars.gitUsername;
  hmUGP = hmUseGlobalPkgs; # from specialArgs, default false
  niriEnable = vars.niriEnable or false;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = hmUGP;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username host profile; };
    users.${username} = {
      # HM pkgs configuration:
      # With useGlobalPkgs=false, Home Manager uses its own pkgs instance and needs allowUnfree here.
      # If you enable home-manager.useGlobalPkgs=true in the future, remove or disable this to avoid conflicts.
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./../home
        inputs.catppuccin.homeModules.catppuccin
      ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
      };
      programs.home-manager.enable = true;

      catppuccin = {
        bottom = {
          enable = true;
          flavor = "mocha";
        };
      };
    };
  };
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [
      "adbusers"
      "docker" # needed for docker access w/o sudo
      "video"
      "input"
      "render"
      "libvirtd" # Needed for VirtMgr
      "lp"
      "networkmanager"
      "scanner"
      "ollama" # local AI access
      "wheel" # needed for sudo access
      "vboxusers" # needed for Virtual box
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = [ "${username}" ];
}
