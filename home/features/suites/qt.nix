{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.themes.qt;
in {
  options.features.themes.qt.enable = mkEnableOption "qt theme";

  config = mkIf cfg.enable {
    qt = {
      enable = true;
    };
  };
}
