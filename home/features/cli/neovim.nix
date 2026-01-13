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
        #timeoutlen = 500;
        termguicolors = true;
        completeopt = "menuone,noselect";

        # Tab settings
        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;
        shiftround = true;
        autoindent = true;
        smartindent = true;

        # Line numbers
        number = true;
        relativenumber = true;
        wrap = false;
        cursorline = true;
        signcolumn = "yes";
        scrolloff = 8;
        sidescrolloff = 5;

        # Search
        ignorecase = true;
        smartcase = true;
        incsearch = true;
        hlsearch = true;

        # Swap
        swapfile = true;
        backup = false;
        writebackup = false;
        undofile = true;
      };

      keymaps = [
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

        # LSP
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
      ];

      plugins = {
        lsp = {
          enable = true;
          servers = {
            # Frontend
            vue_ls.enable = true; # Vue.js
            ts_ls.enable = true; # TS
            jsonls.enable = true;
            cssls.enable = true;
            python.enable = true;
            rust.enable = true;
            nixd.enable = true;
          };
        };
        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              lua = [ "stylua" ];
              nix = [ "nixfmt" ];
              vue = [ "prettier" ];
              python = [ "black" ];
              rust = [ "rustfmt" ];
              html = [ "prettier" ];
              css = [ "prettier" ];
              javascript = [ "prettier" ];
              typescript = [ "prettier" ];
              json = [ "prettier" ];
            };
            format_on_save = {
              timeout_ms = 500;
              lsp_format = "prefer";
            };
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

        lualine = {
          enable = true;
          settings = {
            options = {
              icons_enabled = true;
            };
          };
        };

        telescope = {
          enable = true;
          extensions."fsf-native" = {
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

        neo-tree = {
          enable = true;
        };

        cmp = {
          autoLoad = true;
          autoEnableSources = true;
          settings.sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };

        langmapper = {
          enable = true;
          autoLoad = true;
        };

        # Deps for icons
        web-devicons.enable = true;
      };
      extraPackages = [
        pkgs.stylua # For Lua
        pkgs.nixfmt # For Nix (if using nixfmt; alternatively pkgs.nixpkgs-fmt if you switch to "nixpkgs_fmt" in conform)
        pkgs.nodePackages.prettier # For Vue, HTML, CSS, JS, TS, JSON
        pkgs.black # For Python
        pkgs.rustfmt # For Rust
      ];
    };
  };
}
