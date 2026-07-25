{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.cli.neovim;
in
{
  options.features.cli.neovim.enable = mkEnableOption "enable extended neovim configuration";
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];
  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
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
          pattern = [ "nix" ];
          command = "setlocal nowrap";
        }
      ];
      keymaps = [
        # Сохранение и выход
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
        # Telescope
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
        # Project-wide search (LazyVim style)
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
        # NOTE: LSP keymaps (gd, gr, K, grn, gra, [d/]d, ...) are defined below
        # via `plugins.lsp.keymaps`, so they are only bound in buffers where an
        # LSP client is actually attached (see `keymapsOnEvents.LspAttach`).
        # Gitsigns
        {
          mode = "n";
          key = "<leader>lp";
          action = "<cmd>lua require('gitsigns').preview_hunk()<CR>";
          options.silent = true;
        }
        # Lazygit
        {
          mode = "n";
          key = "<leader>lg";
          action = "<cmd>LazyGit<CR>";
          options.silent = true;
        }
        # Neotree
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
            nixd.enable = true;
            # Python: basedpyright for types/navigation, ruff for lint/format
            # (ruff's hover is disabled so basedpyright's richer hover wins).
            basedpyright.enable = true;
            ruff = {
              enable = true;
              onAttach.function = ''
                client.server_capabilities.hoverProvider = false
              '';
            };
            # TypeScript/JavaScript type-checking (tsc) + navigation.
            ts_ls.enable = true;
            # Fast JS/TS/JSON linting & formatting.
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
              timeout_ms = 500;
              lsp_format = "fallback";
            };
          };
        };
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
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
        # Applies the Noctalia matugen palette via require('base16-colorscheme')
        # from ~/.config/nvim/lua/matugen.lua (see extraConfigLua + noctalia.nix).
        pkgs.vimPlugins.base16-nvim
      ];
      extraConfigLua = ''
        -- Noctalia matugen palette. Written to ~/.config/nvim/lua/matugen.lua by
        -- the theme.templates.user.neovim template (see noctalia.nix); it is
        -- absent until Noctalia first applies a theme, so load it defensively.
        -- The literal string pcall(require, 'matugen') below also matches the
        -- guard in the upstream template's post_hook, keeping it a no-op here.
        local ok, matugen = pcall(require, 'matugen')
        if ok and type(matugen) == "table" and matugen.setup then
          pcall(matugen.setup)
        end
      '';
      extraPackages = [
        pkgs.stylua
        pkgs.nixfmt
        pkgs.hunspell
        pkgs.hunspellDicts.ru-ru
        pkgs.hunspellDicts.en-us
        pkgs.prettier
        # Required by Telescope for project-wide file/text search.
        pkgs.ripgrep
        pkgs.fd
      ];
    };
  };
}
