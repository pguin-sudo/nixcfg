{ config, lib, pkgs, nvf, inputs, ... }:
with lib; let
  cfg = config.features.cli.neovim;
in
{
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

          lsp = {
            enable = true;
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

          languages = {
            enableLSP = true;
            enableTreesitter = true;
            
            nix.enable = true;
            rust.enable = true;
            python.enable = true;
            markdown.enable = true;
            clang.enable = true;
          };
        };  
      };
    };
  };
}
