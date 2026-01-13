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
    inputs.nixvim.homeManagerModules.nixvim
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
        wrap = false;
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

        # LSP базовые действия
        {
          mode = "n";
          key = "gd";
          action = "<cmd>lua vim.lsp.buf.definition()<CR>";
          options.silent = true;
        }
        {
          mode = "n";
          key = "gr";
          action = "<cmd>lua vim.lsp.buf.references()<CR>";
          options.silent = true;
        }
        {
          mode = "n";
          key = "K";
          action = "<cmd>lua vim.lsp.buf.hover()<CR>";
          options.silent = true;
        }
        {
          mode = "n";
          key = "rn";
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          options.silent = true;
        }
        {
          mode = "n";
          key = "<leader>d";
          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
          options.silent = true;
        }

        # Code actions — "предложить решить проблему"
        {
          mode = [
            "n"
            "v"
          ];
          key = "<leader>a";
          action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
          options = {
            silent = true;
            desc = "LSP: Code actions / quickfix suggestions";
          };
        }

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

        # Venv selector
        {
          mode = "n";
          key = "<leader>vs";
          action = "<cmd>VenvSelect<CR>";
          options.silent = true;
        }
      ];

      plugins = {
        lsp = {
          enable = true;
          servers = {
            # Frontend / Vue
            vue_ls = {
              enable = true;
              filetypes = [
                "vue"
                "typescript"
                "javascript"
                "javascriptreact"
                "typescriptreact"
                "json"
              ];
              init_options = {
                typescript.tsdk = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
                vue.hybridMode = false;
              };
            };
            ts_ls.enable = false;

            jsonls.enable = true;
            cssls.enable = true;

            # Python — basedpyright + ruff
            basedpyright = {
              enable = true;
              package = pkgs.basedpyright;
              cmd = [
                "basedpyright-langserver"
                "--stdio"
              ];
              filetypes = [ "python" ];
              settings = {
                basedpyright = {
                  analysis = {
                    autoSearchPaths = true;
                    diagnosticMode = "workspace";
                    useLibraryCodeForTypes = true;
                    typeCheckingMode = "strict";
                    diagnosticSeverityOverrides = {
                      reportUnusedImport = "none"; # Ruff ловит F401
                      reportUnusedVariable = "none";
                      reportDuplicateImport = "none";
                      reportUnusedParameter = "none";
                      # reportMissingTypeStubs = "warning";  # можно оставить, если хочешь
                    };
                  };
                };
                python.venvPath = "${builtins.getEnv "HOME"}/.cache/pypoetry/virtualenvs";
              };
            };

            ruff.enable = true; # ruff как LSP для диагностик (но основные — basedpyright)

            nixd.enable = true;
            # rust_analyzer.enable = true;  # если понадобится — раскомментируй
          };
        };

        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              lua = [ "stylua" ];
              nix = [ "nixfmt" ];
              vue = [ "prettier" ];
              python = [
                "ruff_format"
                "ruff_fix"
              ];
              rust = [ "rustfmt" ];
              html = [ "prettier" ];
              css = [ "prettier" ];
              javascript = [ "prettier" ];
              typescript = [ "prettier" ];
              json = [ "prettier" ];
            };
            formatters = {
              ruff_format = {
                command = "${pkgs.ruff}/bin/ruff";
                args = [
                  "format"
                  "--quiet"
                  "--stdin-filename"
                  "$FILENAME"
                  "-"
                ];
              };
              ruff_fix = {
                command = "${pkgs.ruff}/bin/ruff";
                args = [
                  "check"
                  "--fix"
                  "--quiet"
                  "--exit-zero"
                  "--stdin-filename"
                  "$FILENAME"
                  "-"
                ];
              };
            };
            format_on_save = {
              timeout_ms = 500;
              lsp_format = "fallback"; # сначала ruff, потом LSP (basedpyright)
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
        colorizer = {
          enable = true;
          settings = {
            RRGGBBAA = true;
            css = true;
            mode = "virtual";
          };
        };
        web-devicons.enable = true;

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
          grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
            python
            lua
            nix
            vue
            javascript
            typescript
            json
            html
            css
            rust
          ];
        };
      };

      extraPlugins = [
        pkgs.vimPlugins.venv-selector-nvim
      ];

      extraConfigLua = ''
        require("venv-selector").setup({
          search = {
            poetry = true,
          },
          parents = 2,
        })
      '';

      extraPackages = [
        pkgs.stylua
        pkgs.nixfmt
        pkgs.nodePackages.prettier
        pkgs.nodePackages.typescript
        pkgs.rustfmt
        pkgs.ruff
        pkgs.basedpyright
      ];
    };
  };
}
