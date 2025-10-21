{ lib, host, ... }:
let
  # Enable ssh-agent only on selected hosts by prefix
  agentHosts = [ "ixas" "mini-intel" "prometheus" ];
  enableAgent = lib.any (prefix: lib.hasPrefix prefix host) agentHosts;
in
{
  programs.ssh = {
    enable = true;
    startAgent = enableAgent;
    defaultKeyLifetime = "15m";

    # This is where you can add raw ssh_config lines for global settings
    extraConfig = ''
      PasswordAuthentication Yes
      PubkeyAuthentication yes
      HostbasedAuthentication no
      KbdInteractiveAuthentication Yes

      # Performance: Reuse a single connection for multiple sessions to the same host
      ControlMaster auto
      ControlPath ~/.ssh/sockets/%r@%h-%p
      ControlPersist 15m

      # Convenience: A visual representation of the host key on first connect
      VisualHostKey yes
      ssh-add ~/.ssh/id_ed25519

    '';

    # Define host-specific settings
    matchBlocks = {
      # Example for codberg
      "codeberg.com" = {
        user = "git";
        hostname = "codberg.com";
        # Tells SSH to use this specific key for this host
        identityFile = "~/.ssh/id_ed25519_codberg";
      };

      # Example for a personal server with a custom port and user
      "my-server" = {
        hostname = "server.my-domain.com";
        user = "usrname";
        port = 2222;
        # Forward the ssh-agent so you can ssh from my-server to another server
        # without needing to enter your passphrase again.
        # WARNING: Only use this for servers you trust completely.
        forwardAgent = true;
      };

      # A wildcard for all hosts
      # "*" = {
      # Use a more secure key exchange algorithm by default
      # This is generally handled well automatically, but can be specified
      # KexAlgorithms = "sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256 @libssh.org";
      #};
    };
  };
}
