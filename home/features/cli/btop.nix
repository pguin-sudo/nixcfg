{ config, lib, ... }:
with lib; let
  cfg = config.features.cli.btop;
in
{
  options.features.cli.btop.enable = mkEnableOption "enable extended btop configuration";

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings.color_theme = "tokyo-storm";
      settings.theme_background = false;
    };
  };
}
