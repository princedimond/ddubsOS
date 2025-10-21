{
  description = "ddubsOS";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://vicinae.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Not using for warp-terminal
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    garuda.url = "gitlab:garuda-linux/garuda-nix-subsystem/stable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wfetch = {
      type = "github";
      owner = "iynaix";
      repo = "wfetch";
    };

    ags = {
      type = "github";
      owner = "aylur";
      repo = "ags";
      ref = "v1";
    };

    # Source for hyprpanel until nixplg available
    hyprpanel = {
      url = "github:jas-singhfsu/hyprpanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri (provides NixOS and Home Manager modules)
    niri = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development environment management
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser beta
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add support for specific hardware
    # Go here for list of supported nixos-hardware
    #  https://github.com/NixOS/nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Vicinae - High-performance native launcher
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Current Warp Terminal - bleeding edge version
    warp-terminal-current = {
      url = "github:dwilliam62/war-terminal/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository (NUR)
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      nix-flatpak,
      home-manager,
      garuda,
      chaotic,
      nixos-hardware,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      pkgsStable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      # Back-compat defaults used by legacy profile-named outputs
      host = "PD-5CG84633PQ";
      username = "princedimond";
      profile = "intel";
      # Toggle: make Home Manager share global pkgs (set to true to enable)
      # DO NOT ENABLE at this time!!
      hmUseGlobalPkgs = false;

      # Legacy: build by GPU profile name (kept for compatibility)
      mkNixosConfig =
        gpuProfile:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username host;
            inherit profile hmUseGlobalPkgs;
            stablePkgs = pkgsStable;
          };
          modules = [
            (
              { ... }:
              {
                nixpkgs.config = {
                  allowUnfree = true;
                };
              }
            )
            ./modules/nix-caches.nix
            # had one for python that fails to build still
            # Saving this as template for future overlays
            ./modules/core/overlays.nix
            ./modules/core/niri-session.nix
            ./profiles/${gpuProfile}
            ./modules/home/suckless/dwm-session.nix
            inputs.catppuccin.nixosModules.catppuccin
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

      # New: build by host name (preferred going forward)
      hostsDir = ./hosts;
      hostsAttr = builtins.readDir hostsDir;
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs (name: type: type == "directory") hostsAttr
      );

      defaultProfileFor = hostName: "amd"; # simple default; can be refined per-host later

      mkHostConfig =
        {
          hostName,
          gpuProfile ? defaultProfileFor hostName,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username hmUseGlobalPkgs;
            host = hostName;
            profile = gpuProfile;
            stablePkgs = pkgsStable;
          };
          modules = [
            (
              { ... }:
              {
                nixpkgs.config = {
                  allowUnfree = true;
                };
              }
            )
            ./modules/nix-caches.nix
            ./modules/core/overlays.nix
            ./modules/core/niri-session.nix
            ./profiles/${gpuProfile}
            ./modules/home/suckless/dwm-session.nix
            inputs.catppuccin.nixosModules.catppuccin
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

      nixosByHost = nixpkgs.lib.genAttrs hostNames (hn: mkHostConfig { hostName = hn; });
    in
    {
      # Transitional: keep legacy profile-named configs and add host-named configs
      nixosConfigurations = {
        amd = mkNixosConfig "amd";
        nvidia = mkNixosConfig "nvidia";
        nvidia-laptop = mkNixosConfig "nvidia-laptop";
        amd-hybrid = mkNixosConfig "amd-hybrid";
        intel = mkNixosConfig "intel";
        vm = mkNixosConfig "vm";
      }
      // nixosByHost;

      # Formatter and basic checks
      formatter = forAllSystems (pkgs: pkgs.alejandra);
      checks = forAllSystems (pkgs: {
        formatting = pkgs.runCommand "formatting" { buildInputs = [ pkgs.alejandra ]; } ''
          alejandra --check .
          touch $out
        '';
      });

      # Expose selected stable packages as flake outputs for convenience
      packages = nixpkgs.lib.genAttrs systems (
        system:
        let
          stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          warp-terminal-stable = stable.warp-terminal;
        }
      );
    };
}
