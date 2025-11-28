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
            tabstop = 4;
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
            inlayHints.enable = true;
            #lspsaga.enable = true;
          };

          languages = {
            enableTreesitter = true;
            enableFormat = true;

            nix.enable = true;
            rust.enable = true;
            markdown.enable = true;
            clang.enable = true;

            python.enable = true;

            html.enable = true;
            css.enable = true;
            ts.enable = true;
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
        };
      };
    };
  };
}
