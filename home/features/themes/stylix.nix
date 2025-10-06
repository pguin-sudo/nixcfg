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

      targets = {
        gtk.enable = true;
        qt.enable = true;

        firefox.enable = false; # Define theme for firefox manually
      };
    };
  };
}
