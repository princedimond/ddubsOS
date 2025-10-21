{ ... }:
{
  services = {
    flatpak = {
      enable = true;

      # List the Flatpak applications you want to install
      # Use the official Flatpak application ID (e.g., from flathub.org)
      packages = [
        "com.github.tchx84.Flatseal" # manage flatpak permissions
        #"com.rtosta.zapzap"          #whatsapp client
        "io.github.flattool.Warehouse" # Manage flatpaks
        "it.mijorus.gearlever" # Manage AppImages
        "io.github.freedoom.Phase1" # classic doom
        "io.github.freedoom.Phase2" # classic doom
        #"io.github.dvlv.boxbuddyrs" #GUI for distrobox but I use native package
        "com.github.k4zmu2a.spacecadetpinball"
        "de.schmidhuberj.tubefeeder" # watch YT videos
        # If you prefer the native OBS, comment this out
        # and set `enableObs=true;` in your hosts `variables.nix` file
        # Note the flatpak is the officialy support package
        #"com.obsproject.Studio"
        # "io.github.chidiwilliams.Buzz"  # Local voice transcription 50-50
        # Add other Flatpak IDs here, e.g., "org.mozilla.firefox"
      ];

      # Optional: Automatically update Flatpaks when you run nixos-rebuild swit ch
      update.onActivation = true;
    };
  };
}
