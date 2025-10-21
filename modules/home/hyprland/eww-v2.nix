# ~/ddubsos/modules/home/eww.nix
_: {
  programs.eww = {
    enable = true;

    # Point to your new source directory.
    # The `builtins.path` ensures Nix properly tracks this directory as a source.

    configDir = builtins.path {
      path = ./eww-config; # Relative path to the directory you just created
      name = "eww-config-source"; # A name for Nix's internal tracking (can be anything descriptive)
    };

    # You do NOT need to specify yuck = "" or scss = "" if you're using configDir this way.
    # Home Manager will symlink the *contents* of ./eww-config.
  };
}
