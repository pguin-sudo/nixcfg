{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    globals.mapleader = " ";

    opts = {
      mouse = "a";
      splitbelow = true;
      splitright = true;
      termguicolors = true;
      completeopt = "menuone,noselect";
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      shiftround = true;
      autoindent = true;
      smartindent = true;
      number = true;
      relativenumber = true;
      cursorline = true;
      signcolumn = "yes";
      scrolloff = 8;
      sidescrolloff = 5;
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;
      swapfile = true;
      backup = false;
      writebackup = false;
      undofile = true;
    };

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "markdown" ];
        command = "setlocal wrap | setlocal linebreak | setlocal breakindent | setlocal spell spelllang=ru,en | setlocal conceallevel=2";
      }
      {
        event = [ "FileType" ];
        pattern = [ "rust" ];
        command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab";
      }
      {
        event = [ "FileType" ];
        pattern = [ "nix" ];
        command = "setlocal nowrap";
      }
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format({ lsp_format = 'fallback', timeout_ms = 3000 })<CR>";
        options = {
          silent = true;
          desc = "Format buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader><space>";
        action = "<cmd>Telescope find_files<CR>";
        options = {
          silent = true;
          desc = "Find files";
        };
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>Telescope live_grep<CR>";
        options = {
          silent = true;
          desc = "Grep in project";
        };
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "<cmd>Telescope grep_string<CR>";
        options = {
          silent = true;
          desc = "Search word under cursor";
        };
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>Telescope oldfiles<CR>";
        options = {
          silent = true;
          desc = "Recent files";
        };
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Telescope diagnostics<CR>";
        options = {
          silent = true;
          desc = "Search diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>lp";
        action = "<cmd>lua require('gitsigns').preview_hunk()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>lg";
        action = "<cmd>LazyGit<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>t";
        action = "<cmd>Neotree<CR>";
        options.silent = true;
      }
    ];

    plugins = {
      lsp = {
        enable = true;
        inlayHints = true;

        keymaps = {
          silent = true;

          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
            "<leader>d" = "open_float";
          };

          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gr" = "references";
            "gri" = "implementation";
            "gy" = "type_definition";
            "gO" = "document_symbol";
            "grn" = "rename";
            "<leader>rn" = "rename";
            "gra" = "code_action";
            "<leader>ca" = {
              action = "code_action";
              mode = [
                "n"
                "v"
              ];
            };
            "K" = "hover";
            "<C-k>" = {
              action = "signature_help";
              mode = "i";
            };
          };
        };

        servers = {
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
            installRustfmt = true;

            settings."rust-analyzer" = {
              cargo = {
                allTargets = true;
                buildScripts.enable = true;
              };
              check.command = "clippy";
              checkOnSave = true;
              procMacro.enable = true;
              completion.callable.snippets = "fill_arguments";
            };
          };

          nixd.enable = true;
          basedpyright.enable = true;

          ruff = {
            enable = true;
            onAttach.function = ''
              client.server_capabilities.hoverProvider = false
            '';
          };

          ts_ls.enable = true;
          biome.enable = true;
        };
      };

      conform-nvim = {
        enable = true;

        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            json = [ "biome" ];
            jsonc = [ "biome" ];
            nix = [ "nixfmt" ];
            markdown = [ "prettier" ];
            python = [
              "ruff_fix"
              "ruff_format"
            ];
            javascript = [ "biome" ];
            javascriptreact = [ "biome" ];
            typescript = [ "biome" ];
            typescriptreact = [ "biome" ];
          };

          format_on_save = {
            timeout_ms = 3000;
            lsp_format = "fallback";
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          snippet.expand = "function(args) vim.snippet.expand(args.body) end";
          completion.completeopt = "menu,menuone,noselect";

          mapping = {
            "<Tab>" = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end, { "i", "s" })
            '';
            "<S-Tab>" = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                else
                  fallback()
                end
              end, { "i", "s" })
            '';
            "<CR>" = "cmp.mapping.confirm({ select = false })";
            "<C-Space>" = "cmp.mapping.complete()";
          };

          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      gitsigns = {
        enable = true;

        settings = {
          attach_to_untracked = true;
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 0;
            virt_text_pos = "eol";
          };
        };
      };

      lualine.enable = true;

      telescope = {
        enable = true;
        extensions."fzf-native" = {
          enable = true;
          settings = {
            fuzzy = true;
            override_file_sorter = true;
            override_generic_sorter = true;
            case_mode = "smart_case";
          };
        };
      };

      lazygit = {
        enable = true;
        settings = {
          floating_window_winblend = 0;
          floating_window_scaling_factor = 0.9;
        };
      };

      neo-tree.enable = true;

      langmapper = {
        enable = true;
        autoLoad = true;
      };

      web-devicons.enable = true;

      treesitter = {
        enable = true;

        settings = {
          highlight.enable = true;
          indent.enable = true;
        };

        grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
          rust
          toml
          lua
          nix
          json
          markdown
          markdown_inline
          python
          javascript
          typescript
          tsx
        ];
      };

      markdown-preview = {
        enable = true;
      };
    };

    extraPlugins = [
      pkgs.vimPlugins.vim-markdown
      pkgs.vimPlugins.base16-nvim
      pkgs.vimPlugins.neocord
    ];

    extraConfigLua = ''
      local ok, matugen = pcall(require, 'matugen')
      if ok and type(matugen) == "table" and matugen.setup then
        pcall(matugen.setup)
      end

      require('neocord').setup({
        main_image = "language",
        show_time = true,
        enable_line_number = false,
        editing_text = "Coding",
        reading_text = "Reading",
        terminal_text = "In terminal",
        file_explorer_text = "Browsing files",
        git_commit_text = "Committing",
        plugin_manager_text = "Managing plugins",
        workspace_text = function() end,
        buttons = function() end,
      })
    '';

    extraPackages = [
      pkgs.clippy
      pkgs.biome
      pkgs.ruff
      pkgs.stylua
      pkgs.nixfmt
      pkgs.hunspell
      pkgs.hunspellDicts.ru-ru
      pkgs.hunspellDicts.en-us
      pkgs.prettier
      pkgs.ripgrep
      pkgs.fd
    ];
  };
}
