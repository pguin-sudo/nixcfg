{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.suites.studio;
in {
  options.features.suites.studio.enable = mkEnableOption "studio suite";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      blender
      krita
    ];
  };
}
