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
    ];
  };

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # was using for warp-terminal
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Checking nixvim to see if it's better
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";

    # Google Antigravity (IDE helper)
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wfetch = {
      type = "github";
      owner = "iynaix";
      repo = "wfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agsv1 = {
      url = "github:aylur/ags/v1.9.0";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Current AGS (for projects requiring latest, e.g., tpanel)
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Source for hyprpanel
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
    #nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    oxwm = {
      url = "github:tonybanters/oxwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # awww wallpaper setter
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland from source (track main)
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    mangowc,
    home-manager,
    nix-flatpak,
    nixvim,
    oxwm,
    hyprland,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    systems = ["x86_64-linux"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (sys: f (import nixpkgs {system = sys;}));
    pkgsStable = import inputs.nixpkgs-stable {
      system = system;
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
    mkNixosConfig = gpuProfile:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs username host;
          inherit profile hmUseGlobalPkgs;
          stablePkgs = pkgsStable;
        };
        modules = [
          (
            {...}: {
              nixpkgs.hostPlatform = system;
              nixpkgs.config = {
                allowUnfree = true;
              };
            }
          )
          ./modules/nix-caches.nix
          ./modules/core/overlays.nix
          ./modules/core/niri-session.nix
          ./modules/core/i3-session.nix
          inputs.mangowc.nixosModules.mango
          ./modules/core/mangowc-session.nix
          ./modules/core/oxwm-session.nix
          ./profiles/${gpuProfile}
          ./modules/home/suckless/dwm-session.nix
          inputs.catppuccin.nixosModules.catppuccin
          nix-flatpak.nixosModules.nix-flatpak
          oxwm.nixosModules.default
          hyprland.nixosModules.default
        ];
      };

    # New: build by host name (preferred going forward)
    hostsDir = ./hosts;
    hostsAttr = builtins.readDir hostsDir;
    hostNames = builtins.attrNames (
      nixpkgs.lib.filterAttrs (name: type: type == "directory") hostsAttr
    );

    # GPU/profile selection for host-based configs.
    # We treat the flake-level `profile` (set by installer / zcli update-host)
    # as the single source of truth. All host-based configs built from this
    # flake use that profile unless an explicit gpuProfile is passed.
    #
    # Rationale:
    # - install-ddubsos.sh and `zcli update-host <host> <profile>` always set
    #   the global `profile` correctly at install / host-switch time.
    # - Having a hardcoded fallback like "amd" causes VMs and hybrid
    #   systems to pick the wrong driver stack (amdgpu in a virtio VM, etc.),
    #   which is exactly why Xorg was failing with "no screens found" and why
    #   smartd was incorrectly enabled on the vm profile.
    defaultProfileFor = hostName: profile;

    mkHostConfig = {
      hostName,
      gpuProfile ? defaultProfileFor hostName,
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs username hmUseGlobalPkgs;
          host = hostName;
          profile = gpuProfile;
          stablePkgs = pkgsStable;
        };
        modules = [
          (
            {...}: {
              nixpkgs.hostPlatform = system;
              nixpkgs.config = {
                allowUnfree = true;
              };
            }
          )
          ./modules/nix-caches.nix
          ./modules/core/overlays.nix
          ./modules/core/niri-session.nix
          ./modules/core/i3-session.nix
          inputs.mangowc.nixosModules.mango
          ./modules/core/mangowc-session.nix
          ./modules/core/oxwm-session.nix
          ./profiles/${gpuProfile}
          ./modules/home/suckless/dwm-session.nix
          inputs.catppuccin.nixosModules.catppuccin
          nix-flatpak.nixosModules.nix-flatpak
          oxwm.nixosModules.default
          hyprland.nixosModules.default
        ];
      };

    nixosByHost = nixpkgs.lib.genAttrs hostNames (hn: mkHostConfig {hostName = hn;});
  in {
    # Transitional: keep legacy profile-named configs and add host-named configs
    nixosConfigurations =
      {
        amd = mkNixosConfig "amd";
        nvidia = mkNixosConfig "nvidia";
        nvidia-laptop = mkNixosConfig "nvidia-laptop";
        amd-hybrid = mkNixosConfig "amd-hybrid";
        intel = mkNixosConfig "intel";
        vm = mkNixosConfig "vm";
      }
      // nixosByHost;

    # Formatter and basic checks
    formatter = forAllSystems (
      pkgs:
        pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [pkgs.alejandra];
          text = ''exec alejandra -q .'';
        }
    );
    checks = forAllSystems (pkgs: {
      formatting = pkgs.runCommand "formatting" {buildInputs = [pkgs.alejandra];} ''
        alejandra --check .
        touch $out
      '';
    });

    # Expose selected packages as flake outputs for convenience
    packages = nixpkgs.lib.genAttrs systems (
      sys: let
        pkgs = import nixpkgs {
          system = sys;
          config.allowUnfree = true;
        };
      in {
        warp-terminal-current = pkgs.callPackage ./pkgs/warp-terminal-current/package.nix {
          waylandSupport = true;
        };
      }
    );
  };
}
