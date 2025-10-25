{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.cli.neovim;
in {
  options.features.cli.neovim.enable = mkEnableOption "enable extended neovim configuration";

  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      settings = {
        vim = {
          viAlias = false;
          vimAlias = true;

          options = {
            tabstop = 8;
            softtabstop = 4;
            shiftwidth = 4;
            expandtab = true;
            smarttab = true;
          };

          theme = {
            enable = true;
            transparent = true;
          };

          statusline.lualine.enable = true;
          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;

          lsp = {
            enable = true;
            formatOnSave = true;
          };

          languages = {
            enableTreesitter = true;
            enableFormat = true;

            nix.enable = true;
            rust.enable = true;
            markdown.enable = true;
            clang.enable = true;

            python = {
              enable = true;
              lsp = {
                enable = false;
                server = "basedpyright";
              };
              treesitter.enable = true;
              format = {
                enable = true;
                type = "ruff";
              };
              dap.enable = false;
            };
          };

          diagnostics = {
            enable = true;
            config = {
              update_in_insert = true;
              virtual_lines = true;
              virtual_text = true;
            };
          };

          filetree = {
            neo-tree = {
              enable = true;
            };
          };

          tabline = {
            nvimBufferline.enable = true;
          };

          withPython3 = true;
          python3Packages = ["pynvim"];
        };
      };
    };
  };
}
