{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.firefox;
in {
  options.features.desktop.firefox.enable = mkEnableOption "firefox enable";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
    };
  };
}
