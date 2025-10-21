{ ... }:
{
  # Export OPENCODE/OLLAMA variables via Home Manager (replaces ad-hoc zsh exports)
  home.sessionVariables = {
    # Only set the Ollama connection; opencode/ollama clients expect full URL
    OLLAMA_HOST = "http://192.168.40.60:11434";
  };

  programs.opencode = {
    enable = true;
    settings = {
      theme = "catppuccin";
      model = "ollama/phi3:mini";

      # Explicitly define the Ollama provider so opencode can resolve npm + baseURL
      provider = {
        ollama = {
          npm = "@ai-sdk/ollama";
          name = "Ollama";
          options = {
            baseURL = "http://192.168.40.60:11434";
          };
          models = {
            "phi3:mini" = { };
          };
        };
      };

      autoshare = false;
      autoupdate = false;
    };
  };
}
