{ profile, pkgs, lib, ... }:
{
  # Services to start

  # Move builds from tmpfs to /var/tmp
  #  systemd.services.nix-daemon = {
  #  environment.TMPDIR = "/var/tmp";
  #};

  # Declaratively mask/unmask sleep targets based on profile
  system.activationScripts.ddubsosMaskSleepTargets = lib.mkIf (profile == "nvidia" || profile == "nvidia-laptop") {
    text = ''
      SYSTEMCTL="${pkgs.systemd}/bin/systemctl"
      for u in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
        "$SYSTEMCTL" mask "$u" || true
      done
    '';
  };

  # Ensure they are unmasked on non-Nvidia profiles (in case of profile switches)
  system.activationScripts.ddubsosUnmaskSleepTargets = lib.mkIf (!(profile == "nvidia" || profile == "nvidia-laptop")) {
    text = ''
      SYSTEMCTL="${pkgs.systemd}/bin/systemctl"
      for u in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
        "$SYSTEMCTL" unmask "$u" || true
      done
    '';
  };

  services = {
    gpm = {
      enable = true;
      # Configure the protocol only; the module uses /dev/input/mice by default.
      protocol = "imps2"; # alternatives: "ps/2" (default), "exps2", "evdev"
    };
    # Only if needed (if the mouse isn’t detected automatically):
    # boot.kernelModules = [ "psmouse" "usbhid" ];
    libinput.enable = true; # Input Handling
    fstrim.enable = true; # SSD Optimizer
    gvfs.enable = true; # For Mounting USB & More
    udisks2.enable = true; # Disk management/automount backend
    udev.packages = [ pkgs.libmtp ]; # MTP udev rules for user access
    envfs.enable = true; # For better FHS compatibility
    openssh = {
      enable = true; # Enable SSH
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
      };
      ports = [ 22 ];
    };
    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    gnome.gnome-keyring.enable = true;
    power-profiles-daemon.enable = true;

    logind = {
      settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchDocked = "ignore";
      };
    };

    smartd = {
      enable = if profile == "vm" then false else true;
      autodetect = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 256;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "256/48000";
              pulse.default.req = "256/48000";
              pulse.max.req = "256/48000";
              pulse.min.quantum = "256/48000";
              pulse.max.quantum = "256/48000";
            };
          }
        ];
      };
    };
  };
}
