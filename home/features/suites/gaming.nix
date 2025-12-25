{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.suites.gaming;
in {
  options.features.suites.gaming.enable = mkEnableOption "gaming suite";

  config = mkIf cfg.enable {
    # Steam installed in host config

    home.packages = with pkgs; [
      vesktop
      gzdoom
    ];
  };
}
