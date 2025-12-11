{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      command_timeout = 120;
      palette = lib.mkForce "catppuccin_mocha";
      add_newline = false;

      character = {
        # Note the use of Catppuccin color 'peach'
        success_symbol = "[[](green) ❯](peach)";
        error_symbol = "[[](red) ❯](peach)";
        vimcmd_symbol = "[❮](subtext1)"; # For use with zsh-vi-mode
      };

      palettes = {
        catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };
      };

      # Show all custom modules after defaults and ensure the prompt character is last.
      # Placing $character explicitly at the end prevents any module from appearing after the prompt symbol.
      format = "$all$custom$character";
      # Ensure nothing renders on the right prompt from Starship
      right_format = "";

      directory = {
        read_only = " 󰌾";
        truncation_length = 4;
        style = "bold lavender";
        # Replace ~ with the actual $HOME path dynamically from Home Manager
        home_symbol = config.home.homeDirectory;
      };

      aws.symbol = "  ";
      buf.symbol = " ";
      c.symbol = " ";
      cmake.symbol = " ";
      conda.symbol = " ";
      crystal.symbol = " ";
      dart.symbol = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      fennel.symbol = " ";
      fossil_branch.symbol = " ";

      git_branch = {
        symbol = " ";
        style = "bold mauve";
      };

      git_commit.tag_symbol = "  ";

      golang.symbol = " ";
      guix_shell.symbol = " ";
      haskell.symbol = " ";
      haxe.symbol = " ";
      hg_branch.symbol = " ";
      hostname.ssh_symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      kotlin.symbol = " ";
      lua.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      meson.symbol = "󰔷 ";
      nim.symbol = "󰆥 ";
      nix_shell.symbol = " ";
      nix_shell.disabled = true;
      nodejs.symbol = " ";
      ocaml.symbol = " ";
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      pijul_channel.symbol = " ";
      python.symbol = " ";
      python.disabled = true;
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      rust.symbol = "󱘗 ";
      scala.symbol = " ";
      swift.symbol = " ";
      zig.symbol = " ";
      gradle.symbol = " ";
      # Disable OS module to prevent snowflake icon
      os.disabled = true;

      # Additional language indicators via custom modules
      custom = {
        # JSON
        json = {
          disabled = false;
          symbol = " ";
          style = "bold blue";
          format = "[$symbol]($style)";
          detect_extensions = ["json"];
        };

        # YAML / YML
        yaml = {
          disabled = false;
          symbol = " ";
          style = "bold yellow";
          format = "[$symbol]($style)";
          detect_extensions = ["yaml" "yml"];
        };

        # Nix files outside nix-shell
        nix = {
          disabled = true;
          symbol = " ";
          style = "bold teal";
          format = "[$symbol]($style)";
          detect_extensions = ["nix"];
        };
      };
    };
  };
}
