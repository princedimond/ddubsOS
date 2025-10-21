{ username, ... }: {
  # This is a carry over from ZaneyOS
  # In the future I may remove this
  # I never found it useful

  services.syncthing = {
    enable = false;
    user = "${username}";
    dataDir = "/home/${username}";
    configDir = "/home/${username}/.config/syncthing";
  };
}
