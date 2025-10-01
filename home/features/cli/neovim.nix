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
    inputs.nvf.homeManagerModules.default # Import the nvf module
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
            name = "catppuccin";
            style = "auto";
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
            python.enable = true;
            markdown.enable = true;
            clang.enable = true;
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
