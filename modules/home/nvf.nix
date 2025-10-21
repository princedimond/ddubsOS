{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      lineNumberMode = "number";
      enableLuaLoader = true;
      preventJunkFiles = true;
      options = {
        tabstop = 4;
        shiftwidth = 2;
        wrap = false;
      };

      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers = {
          wl-copy = {
            enable = true;
          };
          xsel = {
            enable = true;
          };
        };
      };

      maps = {
        normal = {
          "<leader>e" = {
            action = "<CMD>Neotree toggle<CR>";
            silent = false;
          };
        };
      };

      diagnostics = {
        enable = true;
        config = {
          virtual_lines = {
            enable = true;
          };
          underline = true;
        };
      };

      keymaps = [
        {
          key = "jk";
          mode = [ "i" ];
          action = "<ESC>";
          desc = "Exit insert mode";
        }
        {
          key = "<leader>nh";
          mode = [ "n" ];
          action = ":nohl<CR>";
          desc = "Clear search highlights";
        }
        {
          key = "<leader>ff";
          mode = [ "n" ];
          action = "<cmd>Telescope find_files<cr>";
          desc = "Search files by name";
        }
        {
          key = "<leader>lg";
          mode = [ "n" ];
          action = "<cmd>Telescope live_grep<cr>";
          desc = "Search files by contents";
        }
        {
          key = "<leader>fe";
          mode = [ "n" ];
          action = "<cmd>Neotree toggle<cr>";
          desc = "File browser toggle";
        }
        {
          key = "<C-h>";
          mode = [ "i" ];
          action = "<Left>";
          desc = "Move left in insert mode";
        }
        {
          key = "<C-j>";
          mode = [ "i" ];
          action = "<Down>";
          desc = "Move down in insert mode";
        }
        {
          key = "<C-k>";
          mode = [ "i" ];
          action = "<Up>";
          desc = "Move up in insert mode";
        }
        {
          key = "<C-l>";
          mode = [ "i" ];
          action = "<Right>";
          desc = "Move right in insert mode";
        }
        {
          key = "<leader>dj";
          mode = [ "n" ];
          action = "<cmd>Lspsaga diagnostic_jump_next<CR>";
          desc = "Go to next diagnostic";
        }
        {
          key = "<leader>dk";
          mode = [ "n" ];
          action = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
          desc = "Go to previous diagnostic";
        }
        {
          key = "<leader>dl";
          mode = [ "n" ];
          action = "<cmd>Lspsaga show_line_diagnostics<CR>";
          desc = "Show diagnostic details";
        }
        {
          key = "<leader>dt";
          mode = [ "n" ];
          action = "<cmd>Trouble diagnostics toggle<cr>";
          desc = "Toggle diagnostics list";
        }
        {
          key = "<leader>t";
          mode = [ "n" ];
          action = "<cmd>ToggleTerm<CR>";
          desc = "Toggle terminal";
        }
        {
          key = "<leader>mp";
          mode = [ "n" ];
          action = ":MarkdownPreview<CR>";
          desc = "Toggle Markdown Preview";
        }

        # Disable accidental F1 help across modes
        {
          key = "<F1>";
          mode = [ "n" "i" "v" "x" "s" "o" "t" "c" ];
          action = "<Nop>";
          desc = "Disable accidental F1 help";
        }
        # Map help to intentional keys
        {
          key = "<leader>h";
          mode = [ "n" ];
          action = ":help<Space>";
          desc = "Open :help prompt";
        }
        {
          key = "<leader>H";
          mode = [ "n" ];
          action = ":help <C-r><C-w><CR>";
          desc = "Help for word under cursor";
        }
      ];

      telescope = {
        enable = true;
      };

      spellcheck = {
        enable = true;
        languages = [ "en" ];
        programmingWordlist = {
          enable = true;
        };
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        lspkind = {
          enable = false;
        };
        lightbulb = {
          enable = false; # even with this disabled enabling lspaga sets lightbulb on
        };
        lspsaga = {
          enable = false; # when enabled getting annoying lightbulb
        };
        trouble = {
          enable = true;
        };
        lspSignature = {
          enable = false;
        };
        otter-nvim = {
          enable = false;
        };
        nvim-docs-view = {
          enable = false;
        };
        servers = {
          hyprls = { };
        };
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;
        nix = {
          enable = true;
        };
        clang = {
          enable = true;
        };
        zig = {
          enable = true;
        };
        python = {
          enable = true;
        };
        markdown = {
          enable = true;
        };
        ts = {
          enable = true;
          lsp = {
            enable = true;
          };
          format.type = "prettierd";
          extensions.ts-error-translator = {
            enable = true;
          };
        };
        html = {
          enable = true;
        };
        lua = {
          enable = true;
        };
        css = {
          enable = true;
          format.type = "prettierd";
        };
        typst = {
          enable = true;
        };
        rust = {
          enable = false;
          crates = {
            enable = false;
          };
        };
      };

      visuals = {
        nvim-web-devicons = {
          enable = true;
        };
        nvim-cursorline = {
          enable = true;
        };
        cinnamon-nvim = {
          enable = true;
        };
        fidget-nvim = {
          enable = true;
        };
        highlight-undo = {
          enable = true;
        };
        indent-blankline = {
          enable = true;
        };
        rainbow-delimiters = {
          enable = true;
        };
      };
      statusline.lualine = {
        enable = true;
        theme = "catppuccin";
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };

      autopairs = {
        nvim-autopairs = {
          enable = true;
        };
      };

      autocomplete = {
        nvim-cmp = {
          enable = true;
        };
        blink-cmp = {
          enable = false;
          friendly-snippets.enable = true;
          setupOpts = {
            completion.documentation.auto_show_delay_ms = 50;
          };
        };
      };

      snippets = {
        luasnip = {
          enable = true;
        };
      };

      tabline = {
        nvimBufferline = {
          enable = true;
        };
      };

      treesitter = {
        context = {
          enable = false;
        };
      };

      binds = {
        whichKey = {
          enable = true;
        };
        cheatsheet = {
          enable = true;
        };
      };

      git = {
        enable = true;
        gitsigns = {
          enable = true;
          codeActions = {
            enable = false;
          };
        };
      };

      projects = {
        project-nvim = {
          enable = true;
        };
      };

      dashboard = {
        dashboard-nvim = {
          enable = true;
        };
        alpha = {
          enable = false;
        };
      };

      filetree = {
        neo-tree = {
          enable = true;
        };
      };

      notify = {
        nvim-notify = {
          enable = true;
          setupOpts.background_colour = "#${config.lib.stylix.colors.base01}";
        };
      };

      utility = {
        preview.markdownPreview = {
          enable = true;
        };
        ccc = {
          enable = false;
        };
        vim-wakatime = {
          enable = false;
        };
        icon-picker = {
          enable = true;
        };
        surround = {
          enable = true;
        };
        diffview-nvim = {
          enable = true;
        };
        motion = {
          hop = {
            enable = true;
          };
          leap = {
            enable = true;
          };
          precognition = {
            enable = false;
          };
        };
        images = {
          image-nvim = {
            enable = false;
          };
        };
      };

      ui = {
        borders = {
          enable = true;
        };
        noice = {
          enable = true;
        };
        colorizer = {
          enable = true;
        };
        illuminate = {
          enable = true;
        };
        breadcrumbs = {
          enable = false;
          navbuddy = {
            enable = false;
          };
        };
        smartcolumn = {
          enable = true;
        };
        fastaction = {
          enable = true;
        };
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit = {
            enable = true;
          };
        };
      };

      session = {
        nvim-session-manager = {
          enable = false;
        };
      };
      extraPackages = with pkgs; [
        hyprls
        nil
      ];
      comments = {
        comment-nvim.enable = true;
      };

      luaConfigPost = ''
        -- Compatibility shim: map legacy/null-ls names so configs requiring
        -- "null_ls" (underscore) or "null-ls" (hyphen) continue to work, and
        -- transparently prefer the maintained none-ls if present.
        local function safe_require(name)
          local ok, mod = pcall(require, name)
          if ok then return mod end
          return nil
        end
        local _none = safe_require('none-ls')
        local _null = _none or safe_require('null-ls')
        if _null then
          package.loaded['null-ls'] = _null
          package.loaded['null_ls'] = _null
        end

        -- Nix LSP (nil) configuration for auto-eval-inputs
        local lspconfig = require('lspconfig')
        lspconfig.nil_ls.setup({
          settings = {
            ['nil'] = {
              nix = {
                auto_eval_inputs = true,
              },
            },
          },
        })

        -- Auto-update programming wordlist on first startup
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            -- Check if dirtytalk dict file exists
            local dict_path = vim.fn.stdpath('data') .. '/site/spell/programming.utf-8.add'
            if vim.fn.filereadable(dict_path) == 0 then
              -- Only run if file doesn't exist to avoid repeated downloads
              vim.schedule(function()
                vim.cmd('DirtytalkUpdate')
              end)
            end
          end,
        })

        -- crates.nvim: avoid passing unknown keys that may trigger warnings
        -- across versions; use defaults and filter specific transient notices.
        do
          local ok, crates = pcall(require, 'crates')
          if ok and type(crates.setup) == 'function' then
            crates.setup({})
          end
        end

        -- Filter crates.nvim transient deprecation/invalid notices about
        -- null-ls/none-ls to keep startup clean.
        do
          local orig = vim.notify
          vim.notify = function(msg, level, opts)
            if type(msg) == 'string' then
              local is_crates = msg:match('crates%.nvim') ~= nil
              local is_null_none = msg:lower():match('null%-?[_-]?ls') or msg:lower():match('none%-?[_-]?ls')
              local is_ignoring_invalid = msg:lower():match('ignoring invalid')
              if is_crates and (is_null_none or is_ignoring_invalid) then
                return
              end
            end
            return orig(msg, level, opts)
          end
        end
      '';
    };
  };

  home.activation = {
    dirtytalkUpdate = ''
      # Create the spell directory if it doesn't exist
      mkdir -p "$HOME/.local/share/nvim/site/spell"

      # Try to run DirtytalkUpdate in headless mode with better error handling
      if ! ${config.programs.nvf.finalPackage}/bin/nvim --headless -c "DirtytalkUpdate" -c "qa!" 2>/dev/null; then
        echo "Note: DirtytalkUpdate will run automatically on first Neovim startup"
      fi
    '';
  };
}
