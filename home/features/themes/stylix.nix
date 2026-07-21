{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.themes.stylix;
in
{
  options.features.themes.stylix.enable = mkEnableOption "stylix theme";

  config = mkMerge [
    {
      # Always available so consumers that only need a color source (e.g.
      # features.themes.rgb) work even with the rest of stylix's theming
      # (features.themes.stylix.enable) turned off.
      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    }
    (mkIf cfg.enable {
      stylix = {
        enable = true;

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

        opacity = {
          applications = 0.3;
          terminal = 0.3;
          desktop = 0.3;
          popups = 0.3;
        };

        targets = {
          firefox.enable = false; # Define theme for firefox manually

          waybar.enable = false;
          zed.enable = false; # Zed config is managed manually
        };
      };
    })
  ];
}
