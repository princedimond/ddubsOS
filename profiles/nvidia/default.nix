{host, ...}: {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core
    ../../modules/home/gui-apps/davinci-resolve.nix
    ../../modules/services/openwebui-ollama.nix
  ];
  # Enable GPU Drivers
  drivers.amdgpu.enable = false;
  drivers.nvidia.enable = true;
  drivers.nvidia-prime.enable = false;
  drivers.intel.enable = false;
  vm.guest-services.enable = false;
  
  # Enable OpenWebUI with Ollama for AI/LLM work
  services.openwebui-ollama.enable = true;
}
