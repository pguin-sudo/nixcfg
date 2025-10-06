{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.themes.stylix;
in {
  options.features.themes.stylix.enable = mkEnableOption "stylix theme";

  imports = [inputs.stylix.homeModules.stylix];

  config = mkIf cfg.enable {
    stylix = {
      enable = true;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      polarity = "dark";

      cursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      fonts = {
        sizes = {
          applications = 12;
          desktop = 10;
        };

        serif = {
          package = pkgs.libertinus;
          name = "Libertinus Serif";
        };

        sansSerif = {
          package = pkgs.inter;
          name = "Inter Variable";
        };

        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode";
        };
      };

      opacity.terminal = 0.3;

      targets = {
        firefox.enable = false; # Define theme for firefox manually
      };
    };
  };
}
